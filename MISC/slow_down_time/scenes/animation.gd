extends Node2D

func _ready():
	pass


func slow_down(val: bool, factor: float):
	$AnimationPlayer.playback_speed = factor
