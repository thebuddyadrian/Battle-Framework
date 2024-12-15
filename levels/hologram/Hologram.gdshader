shader_type spatial;

render_mode unshaded;

uniform vec4 modelColor : source_color;
uniform vec4 wireframeColor : source_color;

uniform float width : hint_range(0.0, 15.) = 1.;
uniform float modelOpacity : hint_range(0.0, 1.0) = 1.;

uniform bool filtered = false;

const vec3 vectors[3] = {
	vec3(1.0, 0.0 ,0.0),
	vec3(0.0, 1.0 ,0.0),
	vec3(0.0, 0.0 ,1.0)
};

varying vec3 baryCoord;

void vertex()
{
	baryCoord = vectors[VERTEX_ID % 3];
}

void fragment() {
	vec3 dBaryCoordX = dFdx(baryCoord);
	vec3 dBaryCoordY = dFdy(baryCoord);
	vec3 dBaryCoord  = sqrt(dBaryCoordX*dBaryCoordX + dBaryCoordY*dBaryCoordY);

	vec3 remap = smoothstep(
		vec3(0.0),
		dBaryCoord * width,
		baryCoord
	);
	
	remap = filtered ? remap : step(.5, remap);

	float closestEdge = min(min(remap.x, remap.y), remap.z);

	ALBEDO = mix(wireframeColor, modelColor, closestEdge).xyz;
	ALPHA = mix(1., modelOpacity, closestEdge);
}