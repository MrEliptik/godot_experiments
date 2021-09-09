shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 color = vec4(0.5,0.5,1.0,1.0);

void fragment() {
	vec2 uv = (UV - vec2(0.5)) * 2.0;
	float r = uv.x * uv.x + uv.y * uv.y;
	
	bool in_circle = abs(r-0.1) < 0.5 && abs(r-0.1) > 0.3;
	bool in_tri = uv.y < -0.5 && 1.0-uv.x > -uv.y && -uv.x < 1.0+uv.y;
	
	float c = float(in_tri || in_circle);
	
	ALBEDO = c * color.xyz;
	ALPHA = c;
}