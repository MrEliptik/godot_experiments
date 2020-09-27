extends Spatial

var picked_up_by = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func pick_up(by):
	if picked_up_by == by:
		return
		
	if picked_up_by:
		pass
		#let_go()
		
	picked_up_by = by
	
	# turn of physics for our pickable object	
	#mode = RigidBody.MODE_STATIC
	#collision_layer = 0
	#collision_mask = 0
	
	# now reparent it
	#original_parent.remove_child(self)
	#picked_up_by.add_child(self)
	
	# reset our transform
	transform = Transform()

func set_selectable_material(material):
	$"RigidBody/Dirty Crate".material_override = material
	
	
	
	
