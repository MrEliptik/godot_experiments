extends RigidBody

const highlight = preload("res://visuals/highlight.tres")

onready var original_parent = get_parent()

var picked_up_by = null

var speed = 5.0

var original_transform

func _ready():
	highlight(false)

func _physics_process(delta):
	if !picked_up_by: return
	
	var dist = global_transform.origin.distance_to(picked_up_by.global_transform.origin) 
	var dir = picked_up_by.global_transform.origin - global_transform.origin 
	
	global_transform.origin = lerp(global_transform.origin, picked_up_by.global_transform.origin, speed * delta)


func highlight(val):
	if val:
		$Pawn.material_override = highlight
	else:
		$Pawn.material_override = null

func pick_up(by):
	if picked_up_by == by:
		return
		
	if picked_up_by:
		let_go()
		
	picked_up_by = by
	original_transform = global_transform
	
	# turn of physics for our pickable object
	mode = RigidBody.MODE_KINEMATIC
	#collision_layer = 0
	#collision_mask = 0
	
	# now reparent it
	original_parent.remove_child(self)
	picked_up_by.add_child(self)
	
	# keep the original transform
	global_transform = original_transform
	
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
