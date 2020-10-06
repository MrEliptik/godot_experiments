shader_type canvas_item;

uniform float threshold_val : hint_range(0.0, 1.0);
uniform vec4 ref_color : hint_color;

// https://www.laurivan.com/rgb-to-hsv-to-rgb-for-shaders/
vec3 rgb2hsv(vec3 c)
{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, K.xyz), step(p.x, c.r));
	
	float d = q.w - min(q.w, q.y);
	float e = 1.0e-10;
	
	return vec3(abs(q.z + (q.w - q.y)) / (6.0 * d + e), d / (q.x + e), q.x);
}

void fragment()
{
	vec4 color_in = texture(TEXTURE, UV);
	vec3 color_hsv;
	vec3 ref_hsv;
	
	color_hsv = rgb2hsv(color_in.rgb);
	ref_hsv = rgb2hsv(ref_color.rgb);
	
	float dist = distance(color_hsv, ref_hsv);
	
	// Only set result to pixel if higher than the threshold
    // step saves expensive if statements http://www.shaderific.com/glsl-functions/
	// don't touch alpha, to avoid setting it a 0
    COLOR.rgb = step(dist, threshold_val) * vec3(1.0, 1.0, 1.0);
	
	// set also the alpha to 0 for easier further computation
    //COLOR = step(dist, threshold_val) * vec4(1.0, 1.0, 1.0, 1.0);
}
