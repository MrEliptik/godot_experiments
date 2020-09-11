extends Spatial

signal body_entered(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_ArrowPlacingArea_body_entered(body):
	emit_signal("body_entered", body)


func _on_ArrowPlacingArea_body_exited(body):
	pass # Replace with function body.
