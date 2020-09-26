extends "res://pickableObject.gd"

export (Material) var material = null

var last_position = Vector3()
var delta_position = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	var new_position = global_transform.origin
	if new_position != last_position:
		delta_position = new_position - last_position
		last_position = new_position
		
		#look_at(new_position + delta_position, Vector3.UP)
		
		#$CollisionShape.shape.extents.y = clamp(delta_position.length()-0.1, 0.0, 100.0)
		#$CollisionShape.shape.height = clamp(delta_position.length()-0.1, 0.0, 100.0)
		
		# _add_test_object()
		
func set_start_transform(t):
	delta_position = linear_velocity / Engine.iterations_per_second
	
	$CollisionShape.shape.extents.y = clamp(delta_position.length()-0.1, 0.0, 100.0)
	#$CollisionShape.shape.height = clamp(delta_position.length()-0.1, 0.0, 100.0)
	
	t.origin += delta_position * 0.5
	global_transform = t
	last_position = t.origin
		
func _add_test_object():
	var mesh = CapsuleMesh.new()
	mesh.radius = 0.01
	mesh.mid_height = $CollisionShape.shape.height + 0.08
	
	var new_object = MeshInstance.new()
	new_object.mesh = mesh
	#spawn_point.add_child(new_object)
	new_object.global_transform = $CollisionShape.global_transform
	new_object.set_surface_material(0, material)

func set_material_override(material):
	$arrow/Arrow001.material_override = material

func _on_PickableArrow_body_entered(body):
	pass
	# TODO: check if is a target
#	if body.has_method("hit"):
#		print("arrow hit: ", body)
#		body.hit(self, global_transform.origin)
#	if body.name == "target":
#		# turn of physics for our pickable object	
#		mode = RigidBody.MODE_STATIC
#		collision_layer = 0
#		collision_mask = 0
