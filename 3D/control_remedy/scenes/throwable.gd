extends RigidBody

onready var original_parent = get_parent()

var picked_up_by = null

var rotation_speed = 0.25

func _ready():
	highlight(false)

func _physics_process(delta):
	if !picked_up_by: return
	rotation += Vector3.ONE * delta * rotation_speed

func highlight(val):
	$MeshInstance.mesh.surface_get_material(0).next_pass.set_shader_param("enbale", val)

func pick_up(by):
	if picked_up_by == by:
		return
		
	if picked_up_by:
		let_go()
		
	picked_up_by = by
	
	var original_transform = global_transform
	
	# turn of physics for our pickable object
	mode = RigidBody.MODE_STATIC
	#collision_layer = 0
	#collision_mask = 0
	
	# now reparent it
	original_parent.remove_child(self)
	picked_up_by.add_child(self)
	
	# reset our transform
	$Tween.interpolate_property(self, "global_transform", original_transform, 
		picked_up_by.global_transform, 1.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()

func let_go(impulse = Vector3(0.0, 0.0, 0.0)):
	if picked_up_by:
		# get our current global transform
		var t = global_transform
		
		# reparent it
		picked_up_by.remove_child(self)
		original_parent.add_child(self)
	
		
		# reposition it and apply impulse
		global_transform = t
		mode = RigidBody.MODE_RIGID
		#collision_layer = original_collision_layer
		#collision_mask = original_collision_mask
		apply_impulse(Vector3(0.0, 0.0, 0.0), impulse)
		
		picked_up_by = null
