extends Line2D

func _ready() -> void:
	pass

func update_trajectory(dir: Vector2, speed: float, gravity: float, delta: float) -> void:
	# Test, draw real trajectory
	var max_points = 300
	clear_points()
	var pos: Vector2 = Vector2.ZERO
	var vel = dir * speed
	for i in max_points:
		add_point(pos)
		vel.y += gravity * delta
	
		var collision = $CollisionTest.move_and_collide(vel * delta, false, true, true)
		if collision:
			vel = vel.bounce(collision.normal) * 0.6

		pos += vel * delta
		$CollisionTest.position = pos
