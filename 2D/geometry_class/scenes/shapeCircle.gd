extends Node2D

func _ready() -> void:
	update()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 40.0, Color("#ffff00"))
