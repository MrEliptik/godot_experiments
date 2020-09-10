extends RigidBody

# Remember some state so we can return to it when user drops the objects
onready var original_parent = get_parent()

var original_collision_mask
var original_collision_layer

var picked_up_by = null

func pick_up(by):
	if picked_up_by == by:
		return
		
	if picked_up_by:
		let_go()
		
	picked_up_by = by
	
	# turn of physics for our pickable object	
	mode = RigidBody.MODE_STATIC
	collision_layer = 0
	collision_mask = 0
	
	# now reparent it
	original_parent.remove_child(self)
	picked_up_by.add_child(self)
	
	# reset our transform
	transform = Transform()
		
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
		collision_layer = original_collision_layer
		collision_mask = original_collision_mask
		apply_impulse(Vector3(0.0, 0.0, 0.0), impulse)
		
		picked_up_by = null
		
func _ready():
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask
