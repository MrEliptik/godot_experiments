extends Node2D

onready var camera_1: Camera2D = $Camera2D1
onready var camera_2: Camera2D = $Camera2D2

func _ready() -> void:
	pass 
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if camera_1.current:
			CameraTransition.transition_camera2D(camera_1, camera_2, 2.0)
		else:
			CameraTransition.transition_camera2D(camera_2, camera_1, 2.0)
			
