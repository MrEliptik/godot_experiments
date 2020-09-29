extends Spatial

const ball = preload("res://ball_green.tscn")

onready var gravity_strength = PhysicsServer.area_get_param(get_viewport().find_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY)

var smooth_idx = 0

func _process(delta):
	var accel = Input.get_accelerometer()
	if accel:
		print(accel)
		$Maze.rotation = Vector3(-stepify(accel.y/gravity_strength, 0.01), 0.0, -stepify(accel.x/gravity_strength, 0.01))*(PI/4)

func _unhandled_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		var instance = ball.instance()
		$Balls.add_child(instance)
		instance.global_transform = $Position3D.global_transform
	# On button press
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_Button_toggled(button_pressed):
	if !button_pressed:
		$Maze/Camera.make_current()
		$CanvasLayer/Control/Label.text = "í ¼í¾¥CAMERA FOLLOW MAZE"
	else:
		$Camera.make_current()
		$CanvasLayer/Control/Label.text = "í ½í³·í ½í³·í ½í³·FIXED CAMERA"
