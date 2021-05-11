extends Node2D

func _ready():
	pass

func slow_down(val, factor):
	if val:
		Engine.time_scale = factor
	else:
		Engine.time_scale = 1.0
