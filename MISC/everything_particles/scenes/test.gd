extends Node2D

func _ready() -> void:
	$Viewport.size = $Viewport/Label.rect_size
	$Timer.start($Particles2D.lifetime * $Particles2D.speed_scale)

func _on_Timer_timeout() -> void:
	queue_free()
