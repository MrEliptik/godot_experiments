extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	$Viewport/Camera.look_at($Player.get_node("CameraTarget").global_transform.origin, Vector3.UP)
	$Viewport2/Camera.look_at($Player.get_node("CameraTarget").global_transform.origin, Vector3.UP)
	
	$Screen.get_surface_material(0).next_pass.uv1_offset.x -= delta * 0.05
	$Screen.get_surface_material(0).next_pass.uv1_offset.y += delta * 0.05
