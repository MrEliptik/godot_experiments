extends Node2D

onready var world_env: WorldEnvironment = $WorldEnvironment
onready var brightness_label: Label = $CanvasLayer/Control/VBoxContainer/HBoxContainer/Brightness
onready var contrast_label: Label = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/Contrast
onready var saturation_label: Label = $CanvasLayer/Control/VBoxContainer/HBoxContainer3/Saturation

func _ready() -> void:
	pass

func _on_BrightnessSlider_value_changed(value: float) -> void:
	brightness_label.text = str(value)
	world_env.environment.adjustment_brightness = value

func _on_ContrastSlider_value_changed(value: float) -> void:
	contrast_label.text = str(value)
	world_env.environment.adjustment_contrast = value

func _on_SaturationSlider_value_changed(value: float) -> void:
	saturation_label.text = str(value)
	world_env.environment.adjustment_saturation = value
