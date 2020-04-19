extends Spatial

onready var sphere = $Sphere

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	sphere.get_mesh().radius = 0.125
	sphere.get_mesh().height = 0.25
	sphere.get_node("StaticBody/CollisionShape").shape.radius = 0.125

func _physics_process(delta):
	pass


func _on_ARVROriginWithHandTrackingCustom_left_index_pinching(transform):
	sphere.get_surface_material(0).albedo_color = Color(randf(), randf(), randf())
	sphere.get_mesh().radius = 0.125
	sphere.get_mesh().height = 0.25
	sphere.get_node("StaticBody/CollisionShape").shape.radius = 0.125


func _on_ARVROriginWithHandTrackingCustom_right_index_pinching(transform):
	sphere.get_mesh().radius = 0.25
	sphere.get_mesh().height = 0.5
	sphere.get_node("StaticBody/CollisionShape").shape.radius = 0.25


func _on_ARVROriginWithHandTrackingCustom_left_index_released(transform):
	pass # Replace with function body.


func _on_ARVROriginWithHandTrackingCustom_right_index_released(transform):
	pass # Replace with function body.
