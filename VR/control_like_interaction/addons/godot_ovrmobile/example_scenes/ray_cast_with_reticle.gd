extends RayCast

onready var ray_reticle = $RayReticle

func _physics_process(delta):
	ray_reticle.visible = is_colliding()
	if (ray_reticle.visible):
		ray_reticle.translation = to_local(get_collision_point())

