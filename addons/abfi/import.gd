@tool
extends EditorImportPlugin

enum Presets { DEFAULT }


func _get_importer_name() -> String:
	return "dt.abfi"

func _get_visible_name() -> String:
	return "Font data (Allegro)"

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["png"])

func _get_save_extension() -> String:
	return "fontdata"

func _get_resource_type() -> String:
	return "FontFile"

func _get_preset_count() -> int:
	return 1

func _get_preset_name(preset: int) -> String:
	match preset:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

func _get_import_options(_path, preset: int) -> Array[Dictionary]:
	var options: Array[Dictionary] = [
		{
			name = "ranges",
			default_value = PackedStringArray([""]),
		},
		{
			name = "letter_spacing",
			default_value = 0,
		},
		{
			name = "mipmaps",
			default_value = false,
		},
	]

	match preset:
		Presets.DEFAULT:
			return options
		_:
			return [] as Array[Dictionary]

func _get_option_visibility(_path, _option, _options) -> bool:
	return true

func _get_import_order() -> int:
	return 0

func _get_priority() -> float:
	return 1.0


func _import(
	source_file: String,
	save_path: String,
	options: Dictionary,
	_platform_variants,
	_gen_files
) -> Error:
	# --- validate ranges & make list of glyphs ---
	var ranges := (options.ranges as PackedStringArray)
	var ranges_n := ranges.size()

	if ranges_n == 0:
		push_error("'ranges' must have at least 1 element")
		return ERR_PARSE_ERROR

	var glyphs := PackedInt64Array([])

	for i in ranges_n:
		var r := ranges[i]
		var len := r.length()

		if len == 3:
			if r[1] != "-":
				push_error("second character of range %d must be a '-'" % i)
				return ERR_PARSE_ERROR

			var start := r.unicode_at(0)
			var end := r.unicode_at(2)
			if start > end:
				push_error("range %i's start character code is greater than its end" % i)
				return ERR_PARSE_ERROR
			if start == end:
				push_error("range %i's start and end characters are identical" % i)
				return ERR_PARSE_ERROR

			glyphs.append_array(PackedInt64Array(range(start, end + 1)))

		elif len == 1:
			glyphs.push_back(r.unicode_at(0))
		else:
			push_error("range %i must either be a hyphen-delimited range (eg. A-Z), or a single character" % i)
			return ERR_PARSE_ERROR

	var glyphs_n := glyphs.size()

	# --- load source file ---
	var file := FileAccess.open(source_file, FileAccess.READ)
	var err := file.get_open_error()
	if err:
		push_error("Couldn't open source file")
		return err

	var image := Image.new()
	err = image.load_png_from_buffer(file.get_buffer(file.get_length()))
	file = null
	if err:
		push_error("Couldn't decode source file")
		return err

	# --- iterate over source file's pixels ---
	var image_w := image.get_width()
	var image_h := image.get_height()
	var delimiter: Color
	var font_h := 0

	# the top-left corner defines the delimiter color
	delimiter = image.get_pixel(0, 0)

	# figure out the font height - start by finding the first glyph
	for x in range(1, image_w):
		if image.get_pixel(x, 1) == delimiter:
			continue

		# ...then how far down we can go before finding the delimiter color
		for y in range(1, image_h):
			if image.get_pixel(x, y) == delimiter:
				font_h = y - 1
				break
		if font_h == 0:
			push_error("The first glyph is a longboi (couldn't ascertain height)")
			return ERR_FILE_CORRUPT
		break

	if font_h == 0:
		push_error("Couldn't find the first glyph")
		return ERR_FILE_CORRUPT

	var in_glyph := false
	var glyph_i := 0
	var glyph_lines := []
	var glyph_line := []
	var glyph_surplus := 0

	for y in range(image_h):
		var delimiter_line := false
		var top_line := false

		for x in range(image_w):
			var color := image.get_pixel(x, y)

			# set all delimiter color pixels to transparent as we iterate. the
			# delimiter color bleeds through into the text when it is transformed
			# otherwise (see #1)
			if color == delimiter:
				image.set_pixel(x, y, Color.TRANSPARENT)

			if delimiter_line:
				# if we run into something that isn't the delimiter color on a
				# separator line, the image isn't formatted correctly
				if color != delimiter:
					push_error("Pixel on seperator line isn't delimiter color (%s, %s)" % [x, y])
					return ERR_FILE_CORRUPT
				continue

			if x == 0:
				# is this a separator line?
				var y_in_row := y % (font_h + 1)
				if y_in_row == 0:
					delimiter_line = true
					if color != delimiter:
						push_error("Leftmost pixel isn't delimiter color (%s, %s)" % [x, y])
						return ERR_FILE_CORRUPT
				elif y_in_row == 1:
					top_line = true
				continue

			if (x == image_w - 1) and (color != delimiter):
				push_error("Rightmost pixel isn't delimiter color (%s, %s)" % [x, y])
				return ERR_FILE_CORRUPT
				# note that there's no 'continue' here, as the 'color == delimiter'
				# condition below might be needed to cap off a glpyh

			# if this is the top line of a row, we need to glyph positions in
			# the row
			if top_line:
				# check whether to add a glyph
				if not in_glyph:
					if color != delimiter:
						in_glyph = true

						# if we're seeing surplus glyphs, don't process them
						if glyph_i == glyphs_n:
							continue

						glyph_line.push_back([x, null])

				# check whether to cap off a glyph
				elif color == delimiter:
					in_glyph = false

					# if this was a surplus glyph, increment the count
					if glyph_i == glyphs_n:
						glyph_surplus += 1
						continue

					# otherwise, cap it off
					glyph_line.back()[1] = x
					glyph_i += 1

			else:
				# TODO: for absolute pedantry, we should at this point check
				# there are no delimiter pixels within the glyphs on the
				# following lines. for now, this is probably fine though.
				pass

		if delimiter_line and (y != 0):
			glyph_lines.push_back(glyph_line)
			glyph_line = []

	if glyph_i != glyphs_n:
		push_warning("Missing glyphs from '%c' onwards" % glyphs[glyph_i])
	elif glyph_surplus:
		var total := glyphs_n + glyph_surplus
		push_warning("More glyphs than expected (wanted %d, got %d, discarded %d)" % [glyphs_n, total, glyph_surplus])

	# --- assemble BitmapFont ---
	var font := FontFile.new()

	var spacing := options.letter_spacing as int

	var size := Vector2i(font_h, 0)
	font.set_texture_image(0, size, 0, image)
	font.fixed_size = font_h
	font.allow_system_fallback = false
	font.generate_mipmaps = options.mipmaps
	font.set_cache_descent(0, size.x, font_h)

	glyph_i = 0
	for i in range(glyph_lines.size()):
		var y := 1 + (i * (font_h + 1))

		for x in glyph_lines[i]:
			var rect := Rect2(x[0], y, x[1] - x[0], font_h)
			var advance := rect.size.x + spacing
			var glyph = glyphs[glyph_i]
			font.set_glyph_uv_rect(0, size, glyph, rect)
			font.set_glyph_advance(0, size.x, glyph, Vector2(advance, 0))
			font.set_glyph_texture_idx(0, size, glyph, 0)
			font.set_glyph_offset(0, size, glyph, Vector2.ZERO)
			font.set_glyph_size(0, size, glyph, rect.size)

			glyph_i += 1

	# --- sorted mate ---
	return ResourceSaver.save(font, "%s.%s" % [save_path, _get_save_extension()])
