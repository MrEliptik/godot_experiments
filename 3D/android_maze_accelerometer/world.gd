extends Spatial

const ball = preload("res://ball_green.tscn")
export var smoothing_weight = 0.1 # 10%
export var max_lean = PI/3

onready var gravity_strength = PhysicsServer.area_get_param(get_viewport().find_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY)

var smooth_idx = 0
var last_smoothed_value = Vector3(0.0, 0.0, 0.0)

func _process(delta):
	var accel = Input.get_accelerometer()
	if accel:
		print(accel)
		var rot = Vector3(-accel.y/gravity_strength, 0.0, -accel.x/gravity_strength)*max_lean
		# Exponential filter: yn = w Ã— xn + (1 â€“ w) Ã— yn â€“ 1, last smoothed value (yn â€“ 1) and a new measurement (xn)
		var smoothed_value = exponential_filter(rot, smoothing_weight, last_smoothed_value)
		last_smoothed_value = smoothed_value
		$Maze.rotation = smoothed_value

func exponential_filter(to_smooth, weight, last_value):
	 return Vector3(weight * to_smooth.x + (1 - weight) * last_value.x,
					weight * to_smooth.y + (1 - weight) * last_value.y,
					weight * to_smooth.z + (1 - weight) * last_value.z)

func _on_Button_toggled(button_pressed):
	if !button_pressed:
		$Maze/Camera.make_current()
		$CanvasLayer/Control/Label.text = "í ¼í¾¥CAMERA FOLLOW MAZE"
	else:
		$Camera.make_current()
		$CanvasLayer/Control/Label.text = "í ½í³·í ½í³·í ½í³·FIXED CAMERA"

func _on_SpawnBtn_toggled(button_pressed):
	if $Balls.get_child_count() > 0:
		$Balls.remove_child($Balls.get_child(0))
	var instance = ball.instance()
	$Balls.add_child(instance)
	instance.global_transform = $Maze/Position3D.global_transform
