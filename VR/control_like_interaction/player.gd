extends Spatial

const blackhole = preload("res://blackhole.tscn")
const selectable_material = preload("res://materials/selectedMaterial.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	vr.initialize()
	
func _process(delta):
	pass
#	if $ARVROriginWithHandTracking/RightHand/RayCast.is_colliding():
#		var collider = $ARVROriginWithHandTracking/RightHand/RayCast.get_collider()
#		if collider.has_method("pick_up"):
#			collider.set_selectable_material(selectable_material)
		

func _on_ARVROriginWithHandTracking_left_hand_pinch(btn):
	if (btn == 7): print("Left Index Pinching")
	if (btn == 1): print("Left Middle Pinching")
	if (btn == 2): print("Left Pinky Pinching")
	if (btn == 15): print("Left Ring Pinching")

func _on_ARVROriginWithHandTracking_right_hand_pinch(btn):
	if (btn == 7):
		if $ARVROriginWithHandTracking/RightHand/SpawnPoint.get_child_count() > 0:
			# Launch blackhole
			var black_hole = $ARVROriginWithHandTracking/RightHand/SpawnPoint.get_child(0)
			$ARVROriginWithHandTracking/RightHand/SpawnPoint.remove_child(black_hole)
			black_hole.global_transform = $ARVROriginWithHandTracking/RightHand/SpawnPoint.global_transform
			black_hole.global_transform.origin -= Vector3(black_hole.global_transform.basis.x * 0.5, 0.0, 0.0)
			black_hole.get_node("CollisionShape").disabled = false
			#black_hole.scale = Vector3(1.0, 1.0, 1.0)
			get_parent().add_child(black_hole)
		else:
			# Create blackhole in hand
			var blackhole_instance = blackhole.instance()
			blackhole_instance.get_node("CollisionShape").disabled = true
			$ARVROriginWithHandTracking/RightHand/SpawnPoint.add_child(blackhole_instance)
	if (btn == 1): print("Right Middle Pinching")
	if (btn == 2): print("Right Pinky Pinching")
	if (btn == 15): print("Right Ring Pinching")
