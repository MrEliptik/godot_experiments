extends Control

func _ready():
	print(OS.current_screen)
	get_tree().get_root().set_transparent_background(true)

func zoom_in(who):
	$Tween.stop_all()
	$Tween.interpolate_property(who, "rect_scale", Vector2.ONE, Vector2(1.2, 1.2),
		0.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
	
func zoom_out(who):
	$Tween.stop_all()
	$Tween.interpolate_property(who, "rect_scale", Vector2(1.2, 1.2), Vector2.ONE,
		0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()

func _on_Button_mouse_entered():
	zoom_in($MarginContainer/HBoxContainer/Button)

func _on_Button_mouse_exited():
	zoom_out($MarginContainer/HBoxContainer/Button)

func _on_Button2_mouse_entered():
	pass # Replace with function body.

func _on_Button2_mouse_exited():
	pass # Replace with function body.

func _on_Button3_mouse_entered():
	pass # Replace with function body.

func _on_Button3_mouse_exited():
	pass # Replace with function body.

func _on_Button4_mouse_entered():
	pass # Replace with function body.

func _on_Button4_mouse_exited():
	pass # Replace with function body.

func _on_Button5_mouse_entered():
	pass # Replace with function body.

func _on_Button5_mouse_exited():
	pass # Replace with function body.
