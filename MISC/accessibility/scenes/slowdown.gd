extends Node2D

func _ready() -> void:
	pass

func _on_HSlider_value_changed(value: float) -> void:
	$CanvasLayer/Control/HBoxContainer/Timescale.text = str(value)
	Engine.time_scale = value
