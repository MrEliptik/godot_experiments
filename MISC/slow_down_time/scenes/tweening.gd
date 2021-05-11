extends Node2D

func _ready():
	$Tween.interpolate_property($icon, "scale", Vector2.ZERO, Vector2(0.558, 0.558),
		1.0, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start() 

func slow_down(val: bool, factor: float):
	$Tween.playback_speed = factor

func _on_Tween_tween_all_completed():
	if $icon.scale == Vector2(0.558, 0.558):
		$Tween.interpolate_property($icon, "scale", Vector2(0.558, 0.558), Vector2.ZERO,
			1.0, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.start() 
	else:
		$Tween.interpolate_property($icon, "scale", Vector2.ZERO, Vector2(0.558, 0.558),
			1.0, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.start() 
