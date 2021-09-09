tool
extends ImmediateGeometry

export(Vector3) var end_point = Vector3.ONE
export(float) var width = 1.0
export(NodePath) var end_point_node

func _process(delta):
	if end_point_node != '':
		set_end_point_from_glob_pos(get_node(end_point_node).transform.origin)
	clear()
	
	begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, null)

	set_normal(Vector3(0, 1, 0))
	set_uv(Vector2(0, 1))
	add_vertex(transform_pos(Vector3(-1, 0, 0)))

	set_normal(Vector3(0, 1, 0))
	set_uv(Vector2(1, 1))
	add_vertex(transform_pos(Vector3(1, 0, 0)))

	set_normal(Vector3(0, 1, 0))
	set_uv(Vector2(0, 0))
	add_vertex(transform_pos(Vector3(-1, 0, 1)))

	set_normal(Vector3(0, 1, 0))
	set_uv(Vector2(1, 0))
	add_vertex(transform_pos(Vector3(1, 0, 1)))

	end()

func transform_pos(pos: Vector3) -> Vector3:
	var d = end_point.length()
	var t := Transform()
	t = t.scaled(Vector3(width, 1, d))
	t = t.looking_at(end_point, Vector3.UP)
	t = t.scaled(-Vector3.ONE)
	t.basis.z *= d
	t.basis.x *= width
	return pos.x * t.basis.x + pos.y * t.basis.y + pos.z * t.basis.z

func set_end_point_from_glob_pos(pos: Vector3) -> void:
	end_point = pos - transform.origin
