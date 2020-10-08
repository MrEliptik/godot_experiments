extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_LineEdit_text_changed(new_text):
	$HBoxContainer/HSlider.value = float(new_text)

func _on_HSlider_value_changed(value):
	$HBoxContainer/LineEdit.text = str(value)
	
func get_torque():
	return $HBoxContainer/HSlider.value
