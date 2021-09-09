extends Particles2D

func _ready() -> void:
	$Timer.start(lifetime * speed_scale)
	$Particles2D.emitting = true
	emitting = true

func _on_Timer_timeout() -> void:
	call_deferred("queue_free")
