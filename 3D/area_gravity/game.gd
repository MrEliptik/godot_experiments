extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_toggled(button_pressed):
	$Area/StaticBody/CollisionShape.disabled = !button_pressed
	if button_pressed:
		$CanvasLayer/UI/HBoxContainer/Button.text = "ATTRACTOR COLLISION ON"
	else:
		$CanvasLayer/UI/HBoxContainer/Button.text = "ATTRACTOR COLLISION OFF"
		
func _on_Button2_pressed():
	get_tree().reload_current_scene()

func _on_Button3_toggled(button_pressed):
	get_tree().paused = button_pressed
	if button_pressed:
			$CanvasLayer/UI/HBoxContainer/Button3.text = "UNPAUSE"
	else:
		$CanvasLayer/UI/HBoxContainer/Button3.text = "PAUSE"
