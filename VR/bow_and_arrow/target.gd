extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func hit(body, position):
	if body.has_method("pick_up"):
		body.pick_up(self)

func _on_RigidBody_body_entered(body):
	if body.has_method("pick_up"):
		if body.is_picked_up(): return
		var arrow_pos = body.global_transform
		var arrow_pos_spatial = Spatial.new()
		$Arrows.add_child(arrow_pos_spatial)
		arrow_pos_spatial.global_transform = arrow_pos
		body.get_node("CollisionShape").disabled = true
		body.pick_up(arrow_pos_spatial)
