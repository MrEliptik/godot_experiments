extends RigidBody

func _ready():
	pass 

func _on_Area_body_entered(body):
	if !body.is_in_group("Player"): return
	# Call body.pickup or something
	call_deferred("queue_free")


func _on_LogsPile_body_entered(body):
	if !body.is_in_group("Floor"): return
	$LogHit.play()
