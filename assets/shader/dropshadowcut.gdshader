// Credit to Toadile
shader_type spatial;
render_mode blend_mix, depth_test_disabled, cull_front, unshaded, shadows_disabled;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;

uniform vec4 base_color: source_color;
uniform vec2 near_far=vec2(0.1,100.0);
uniform float inval=0.0;
uniform float match=0.0;

float linearize(float val) {
    val = 2.0 * val - 1.0;
    return val;
}

void fragment() {
	float zdepth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	float zpos = FRAGCOORD.z;
	float diff = zdepth - zpos;
	diff *= 1000.0;
	float sub = 0.0;
	float top = 0.0;
	if (diff >0.0) {
		sub = diff;
		top = diff;
	}
	
	if(top > 1.0){
		top = 1.0;
	}
	
	sub = (1.0-sub)*2.0;
	if(sub != 2.0){
		sub = 0.0;
	}
	else{
		sub = 1.0;
	}
	if(sub < 0.0){
		sub = 0.0;
	}
	
	//float final = sub*2.0+2.0;
	float final = top*1.0;
	
	NORMAL*=-1.0;
	ALBEDO = base_color.rgb;
	ALPHA = sub*-inval*base_color.a;
}