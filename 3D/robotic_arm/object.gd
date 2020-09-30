extends RigidBody


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_color(color):
	$MeshInstance.set_surface_material(0, SpatialMaterial.new())
	$MeshInstance.get_surface_material(0).albedo_color = color

func _on_Lifetime_timeout():
	queue_free()


func _on_Object_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		print("CLICKED")
