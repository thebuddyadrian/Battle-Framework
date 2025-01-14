shader_type spatial;
render_mode unshaded, shadows_disabled;

uniform sampler2D checkerboard : hint_default_white, filter_nearest_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = texture(checkerboard, SCREEN_UV * VIEWPORT_SIZE).xyz;
	ALPHA = texture(checkerboard, SCREEN_UV  * VIEWPORT_SIZE / 2.0).a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
