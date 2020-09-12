extends Spatial

signal body_entered(body)
signal body_exited(body)

signal hand_entered(area)
signal hand_exited(area)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_ArrowPlacingArea_body_entered(body):
	emit_signal("body_entered", body)

func _on_ArrowPlacingArea_body_exited(body):
	emit_signal("body_exited", body)

func _on_RopeArea_area_entered(area):
	emit_signal("hand_entered", area)

func _on_RopeArea_area_exited(area):
	emit_signal("hand_exited", area)
