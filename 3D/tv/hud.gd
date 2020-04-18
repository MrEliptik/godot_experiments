extends Control

signal next
signal previous

func set_scene_name(name):
	$HBoxContainer/HBoxContainer3/Label.text = name

func _on_NextBtn_pressed():
	emit_signal("next")


func _on_PreviousBtn_pressed():
	emit_signal("previous")
