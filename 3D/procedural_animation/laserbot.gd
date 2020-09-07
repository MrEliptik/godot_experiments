extends Spatial

onready var ray = $Head/RayCast
onready var laser_beam = $Head/Laser
onready var laser_emitter = $Head/LaserEmitter

onready var laser_particles = $LaserParticles
onready var laser_particles_emission = $Head/LaserParticlesEmission
onready var laser_particles_charge = $Head/LaserParticlesCharge

# Called when the node enters the scene tree for the first time.
func _ready():
	
	laser_beam.scale = Vector3(0, 0, 0)
	ray.enabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass	

func _physics_process(delta):
	laser_particles.emitting = ray.is_colliding()
	
	if ray.is_colliding():
		var point = ray.get_collision_point()
		
		# Calculate distance from laser emitter to collision point
		var distance = laser_emitter.global_transform.origin.distance_to(point)
		
		# Scale laser beam
		laser_beam.scale.y = distance * 0.143
		
		# Add particles
		laser_particles.transform.origin = to_local(point)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "charge":
		# Fire laser
		ray.enabled = true
		laser_beam.scale.x = 0
		laser_beam.scale.z = 0
		
		$LaserSound.play()
		$Tween.interpolate_property(laser_beam, "scale", 
			Vector3(0, laser_beam.scale.y, 0), Vector3(0.651, laser_beam.scale.y, 0.157), 
			0.1, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
		$Tween.start()
		
		laser_particles_emission.emitting = true
		laser_particles_charge.emitting = false
		$AnimationPlayer2.play("head_up_down")

func _on_LaserTimer_timeout():
	ray.enabled = false
	laser_particles_emission.emitting = false
	$LaserDisappear.play()
	$Tween.interpolate_property(laser_beam, "scale", 
			Vector3(0.651, laser_beam.scale.y, 0.157), Vector3(0, laser_beam.scale.y, 0), 
			0.4, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	$Tween.start()
	
	$AnimationPlayer.play("charge")
	laser_particles_charge.emitting = true
