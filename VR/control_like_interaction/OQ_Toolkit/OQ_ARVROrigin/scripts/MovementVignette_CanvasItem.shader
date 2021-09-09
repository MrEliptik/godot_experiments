shader_type canvas_item;

uniform float r0 = 0.5;
uniform float r1 = 0.8;
uniform vec4 color = vec4(0.0, 0.0, 0.0, 1.0);

varying vec2 center;

void vertex() {
	center = vec2(PROJECTION_MATRIX[0][3], PROJECTION_MATRIX[1][3]);
}

void fragment() {
	float l = length((UV - vec2(0.5))*2.0 - center);
	float v = smoothstep(r0, r1, l);
	COLOR.rgb = color.rgb;
	COLOR.a = v * color.a;
}
