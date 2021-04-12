extends "res://scenes/tree.gd"

func _ready():
	pass
	
func die():
	$CollisionShape.disabled = true
	
	.die()
	
	call_deferred("queue_free")


func _on_Area_body_entered(body):
	if !body.is_in_group("Tree") || body == self: return
	body.take_damage(4)

