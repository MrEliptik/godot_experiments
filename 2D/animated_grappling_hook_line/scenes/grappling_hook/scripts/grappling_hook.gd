extends Node2D

class_name GrapplingHook

@export var curve: Curve

var tween: Tween
var sin_offset: float = 0.0

@onready var line: Line2D = $Line2D
@onready var ray: RayCast2D = $RayCast2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hook"):
		hook()

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	sin_line(wrapf(sin_offset+delta, -1.0, 1.0))
		
func hook() -> void:
	ray.force_raycast_update()
	if not ray.is_colliding(): return
	create_line(ray.get_collision_point(), 200)

# Assumes the point will be global
func create_line(end_point: Vector2, subdiv: int = 25, animated: bool = true) -> void:
	end_point = line.to_local(end_point)
	line.clear_points()
	#line.add_point(Vector2.ZERO)
	
	var direction: Vector2 = Vector2.ZERO.direction_to(end_point)
	var distance: float = Vector2.ZERO.distance_to(end_point)
	
	if animated:
		if tween and tween.is_running():
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		for i in subdiv:
			line.add_point(Vector2.ZERO)
			var point: Vector2 = direction * distance * float(i)/float(subdiv)
			#tween.parallel().tween_callback(line.set_point_position.bind(i, point))
			tween.parallel().tween_method(Callable(func(point: Vector2, index: int): line.set_point_position(index, point)).bind(i), \
				Vector2.ZERO, point, 0.15)
	else:
		for i in subdiv:
			var point: Vector2 = direction * distance * float(i)/float(subdiv)
			#print("Point index %d, val: %.1f,%.1f" % [i, point.x, point.y])
			line.add_point(point)
		
		line.add_point(end_point)

func sin_line(value: float) -> void:
	#print("Sin: ", sin(value))
	for i in line.get_point_count():
		var new_point_position: Vector2 = line.get_point_position(i)
		new_point_position.y = sin(i * value * 25.0) * 50.0
		new_point_position.y *= curve.sample_baked(float(i)/float(line.get_point_count()))
		line.set_point_position(i, new_point_position)
