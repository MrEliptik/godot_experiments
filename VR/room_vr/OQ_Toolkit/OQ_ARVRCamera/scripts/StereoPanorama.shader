shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D stereo_image;

const float M_PI = 3.1415926535897932384626433832795;

void fragment() {
	bool is_right_eye = (PROJECTION_MATRIX[2][0] > 0.0); // use the asymetric projection matrix to figure out what eye we are rendering

	// compute the view direction from the (asymetric) projection matrix
	vec2 uv_interp = FRAGCOORD.xy / VIEWPORT_SIZE * 2.0 - vec2(1.0);
	vec4 asym_proj = vec4(PROJECTION_MATRIX[2][0], PROJECTION_MATRIX[0][0], PROJECTION_MATRIX[2][1], PROJECTION_MATRIX[1][1]);
	vec3 dir = vec3(0.0, 0.0, 1.0);
	dir.x = ((-uv_interp.x - asym_proj.x)) / asym_proj.y;
	dir.y = ((-uv_interp.y - asym_proj.z)) / asym_proj.a;
	dir = mat3(CAMERA_MATRIX) * normalize(-dir);
	
	// from the view dir we now compute the lat-long uv coordinates for env lookup
	float x = (atan(dir.z, dir.x) + M_PI)  / (2.0 * M_PI);
	float y = (acos(dir.y)) / (M_PI); 
	
	y *= 0.5; // use only half of the image
	y += float(is_right_eye)*0.5; // and use the lower half for the right eye
	
	vec2 uv = vec2(x, y);
	
	ALBEDO = texture(stereo_image, uv).xyz;
	
}