shader_type canvas_item;

// --- Uniforms --- //
uniform float resolution: hint_range(0.0, 256.0) = 256.0;

// --- Functions --- //
void fragment() {
	COLOR = texture(TEXTURE, round(UV * (resolution + 1.0) - (UV - 0.5)) / (resolution + 1.0));
}

