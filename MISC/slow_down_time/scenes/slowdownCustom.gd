extends Node2D

func _ready():
	pass

func slow_down(val, factor):
	if val:
		$KinematicBody2D.slow_down(val, factor)
		$Timer.slow_down(val, factor)
		$Particles.slow_down(val, factor)
		$Tweening.slow_down(val, factor)
		$Animation.slow_down(val, factor)
	else:
		$KinematicBody2D.slow_down(val, 1.0)
		$Timer.slow_down(val, 1.0)
		$Particles.slow_down(val, 1.0)
		$Tweening.slow_down(val, 1.0)
		$Animation.slow_down(val, 1.0)
