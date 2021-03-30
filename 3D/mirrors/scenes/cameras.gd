tool
extends Spatial


func _ready():
	$Mirror.mesh.surface_get_material(0).set_shader_param("MirrorTexture", $Viewport.get_texture())
	
func _process(delta):
	var new_translation = $Camera.translation
	new_translation.x *= -1
	$Viewport/MirrorCamera.translation = new_translation
	
	var new_rot = $Camera.rotation
	new_rot.y *= -1
	$Viewport/MirrorCamera.rotation = new_rot
