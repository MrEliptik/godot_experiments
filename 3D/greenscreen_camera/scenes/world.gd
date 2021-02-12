extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	$Viewport/Camera.look_at($Player.get_node("CameraTarget").global_transform.origin, Vector3.UP)
	$Viewport2/Camera.look_at($Player.get_node("CameraTarget").global_transform.origin, Vector3.UP)
