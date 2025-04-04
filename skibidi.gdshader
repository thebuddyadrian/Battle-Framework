shader_type spatial;
render_mode unshaded, shadows_disabled;

uniform sampler2D skibidi_texture : hint_default_white, filter_linear;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = texture(skibidi_texture, SCREEN_UV).xyz;
	ALPHA = texture(skibidi_texture, SCREEN_UV).a;
}
