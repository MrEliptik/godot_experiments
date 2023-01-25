extends Node2D

var intensity: float = 1.0

func _ready() -> void:
	pass

func _on_ShakeBtn_pressed() -> void:
	$Camera2D.add_stress(0.8*intensity)

func _on_VibrateBtn_pressed() -> void:
	Input.start_joy_vibration(0, 0.5*intensity, 0.5*intensity, 1.0)

func _on_HSlider_value_changed(value: float) -> void:
	$CanvasLayer/Control/VBoxContainer/HBoxContainer/Intensity.text = str(value)
	intensity = value


