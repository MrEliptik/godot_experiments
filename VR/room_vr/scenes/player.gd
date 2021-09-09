extends Spatial

onready var portable_menu = $OQ_ARVROrigin/OQ_LeftController/PortableMenu

func _ready():
	pass
	
func _process(delta):
	if !portable_menu.visible: return
	portable_menu.look_at($OQ_ARVROrigin/OQ_ARVRCamera.global_transform.origin, Vector3.UP)
	portable_menu.rotation_degrees.x += 10
	portable_menu.transform.origin = Vector3(0.35, 0.15, -0.1) 
