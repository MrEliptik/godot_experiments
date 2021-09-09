shader_type spatial;
// we skip the vertex transform and assume that the input mesh is in [-0.5, 0.5]
render_mode skip_vertex_transform, cull_disabled, unshaded;

// the positions are in world space; this was a deliberate choice as I personally find
// world space computations much easier to understand and debug; I hope this makes
// tweaking this to your own needs easier
uniform vec3 start_position = vec3(3.0, 1.0, 0.0);
uniform vec3 direction = vec3(-1.25, 2.0, 0.0);
uniform float arc_length = 3.0;

uniform vec4 color = vec4(1.0, 1.0, 0.0, 1.0);



void vertex() {
	vec3 mesh_pos = VERTEX + vec3(0.0, 0.0, 0.5);
	
	vec3 side = normalize(cross(direction, vec3(0.0, 1.0, 0.0)));
	
	float t = mesh_pos.z * arc_length;
	
	vec3 pos = start_position + t * direction - t*t*vec3(0,1,0);
	pos += side * mesh_pos.x;
	
	// final step is to 
	VERTEX = (INV_CAMERA_MATRIX * vec4(pos, 1.0)).xyz;
	UV = vec2(sign(mesh_pos.x), t - TIME * 0.125);
}

void fragment() {
	float v = fract(UV.y * 8.0);
	
	float in_tri = float(UV.x+1.0 > v*1.5 && UV.x < 1.0-v*1.5);
	
	ALBEDO = color.xyz;
	ALPHA = in_tri;
}