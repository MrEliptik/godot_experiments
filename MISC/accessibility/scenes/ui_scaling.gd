extends Node

onready var viewport_size: Vector2 = $AspectRatioContainer/ViewportContainer/Viewport.size

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				$CanvasLayer/HBoxContainer/HSlider.value += 0.1
			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				$CanvasLayer/HBoxContainer/HSlider.value -= 0.1
	
func _on_HSlider_value_changed(value: float) -> void:
	$CanvasLayer/HBoxContainer/Scale.text = str(value)
#	$ViewportContainer.stretch_shrink = value
	$AspectRatioContainer/ViewportContainer/Viewport.size = viewport_size / value
