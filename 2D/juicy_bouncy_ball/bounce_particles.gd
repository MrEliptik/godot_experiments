extends GPUParticles2D

func _ready():
	emitting = true
	$BounceParticles2.emitting = true
	await get_tree().create_timer($BounceParticles2.lifetime + 1.0).timeout
	queue_free()
	
