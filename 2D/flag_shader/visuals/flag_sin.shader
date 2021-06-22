shader_type canvas_item;

uniform float speed = 2.0;
uniform float frequency_y = 5.0;
uniform float frequency_x = 5.0;
uniform float amplitude = 50.0;
uniform float inclination = 50.0;

void vertex() {
	VERTEX.y += sin((UV.x - TIME * speed) * frequency_y) * amplitude * UV.x;
	VERTEX.x += cos((UV.y - TIME * speed) * frequency_x) * amplitude * 0.5 * UV.x;
	VERTEX.x -= UV.y * inclination;
}