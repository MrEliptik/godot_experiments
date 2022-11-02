extends Control

signal goto_2D()
signal goto_3D()
signal transition_smooth()
signal transition_simple()

func _ready() -> void:
	pass 

func _on_2DBtn_pressed() -> void:
	emit_signal("goto_2D")
	
func _on_3DBtn_pressed() -> void:
	emit_signal("goto_3D")

func _on_SmoothBtn_pressed() -> void:
	emit_signal("transition_smooth")

func _on_SimpleBtn_pressed() -> void:
	emit_signal("transition_simple")
