shader_type canvas_item;
uniform float rot = 0.0;
uniform vec2 rot_point = vec2(0.5, 0.5);

// Rotation matrix: https://en.wikipedia.org/wiki/Rotation_matrix

void fragment() {
	float rot_anchored = rot * (1.0 - UV.y);
	mat2 rotation_mat = mat2(vec2(cos(rot_anchored), sin(rot_anchored)), vec2(-sin(rot_anchored), cos(rot_anchored)));
	vec2 centered_uv = UV - rot_point;
	vec2 rotated_uv = centered_uv * rotation_mat;
	rotated_uv = rotated_uv + rot_point;
	
	COLOR = texture(TEXTURE, rotated_uv);
}
