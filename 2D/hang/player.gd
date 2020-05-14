extends RigidBody2D

signal anchor(point, collider)
signal free
signal die

onready var ray = $RayCast2D
onready var sprite = $Sprite

enum COLORS {
	NORMAL,
	DEAD
}

var player_colors = {
	COLORS.NORMAL: Color('50cd81'),
	COLORS.DEAD: Color('c43535'),
}

var anchor = null

var reset = false
var reset_position

var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture.gradient.set_color(0, player_colors[COLORS.NORMAL])
	
func _physics_process(delta):
	update()
	if !reset: contact_monitor = true
	
func _integrate_forces(state):
	if reset:
		state.transform = Transform2D(0, reset_position)
		state.linear_velocity = Vector2()
		dead = false
		reset = false
	
func _draw():
	if dead: return
	if anchor != null:
		draw_line(ray.position, (ray.get_collision_point()-ray.global_position).rotated(-rotation), Color(1, 1, 1), 2)
	#else:
	#	draw_line(ray.position, ray.cast_to.rotated(-rotation), Color(0, 1, 0), 2)

func _input(e):
	if e is InputEventMouseButton && e.button_index == BUTTON_LEFT && e.pressed:	
		# Raycast to position
		ray.cast_to = (e.global_position-ray.global_position).rotated(-rotation)
		print(rad2deg((e.global_position-ray.global_position).angle()))
		#ray.rotation = (e.global_position-ray.global_position).angle() - deg2rad(90)
		#ray.rotation = ray.global_position.angle_to_point(e.global_position)
		# Force update otherwise collision happens next frame
		ray.force_raycast_update()
		if ray.is_colliding():
			$LaunchSound.play()
			var collider = ray.get_collider()
			anchor = ray.get_collision_point()
			print(collider, anchor)
			emit_signal("anchor", anchor, collider)
		else:
			print("click: ", e.position)
	elif e is InputEventMouseButton && e.button_index == BUTTON_RIGHT && e.pressed:
		emit_signal("free")
		anchor = null
		
func reset(pos):
	reset = true
	reset_position = pos
	anchor = null
	sprite.texture.gradient.set_color(0, player_colors[COLORS.NORMAL])

func _on_Player_body_entered(body):
	if reset or dead: return
	#$Sprite.visible = false
	# There's only one color
	sprite.texture.gradient.set_color(0, player_colors[COLORS.DEAD])
	$TrailTimer.stop()
#	$fake_explosion_particles.visible = true
#	$fake_explosion_particles.particles_explode = true
	dead = true
	emit_signal("die")
	$DieSound.play()
	print('dead')


func _on_TrailTimer_timeout():
	var this_trail = preload("res://effects/trail.tscn").instance()
	# give the trail a parent
	get_parent().add_child(this_trail)
	this_trail.position = position
	this_trail.texture = $Sprite.texture
	this_trail.flip_h = $Sprite.flip_h
	this_trail.scale = $Sprite.scale
