extends Spatial

onready var camera_1: Camera = $Camera1
onready var camera_2: Camera = $Camera2

func _ready() -> void:
	pass 
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if camera_1.current:
			CameraTransition.transition_camera3D(camera_1, camera_2, 1.5)
		else:
			CameraTransition.transition_camera3D(camera_2, camera_1, 1.5)
	
