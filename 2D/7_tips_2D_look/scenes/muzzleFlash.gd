extends Particles2D

func _ready() -> void:
	emitting = true
	$Timer.start(lifetime * speed_scale)

func _on_Timer_timeout() -> void:
	call_deferred("queue_free")
