extends RigidBody2D

signal anchor(point, collider)
signal free
signal die
signal swipe(direction)

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

var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture.gradient.set_color(0, player_colors[COLORS.NORMAL])
	
func _physics_process(delta):
	update()
	
func _draw():
	if dead: return
	if anchor != null:
		draw_line(ray.position, (ray.get_collision_point()-ray.global_position).rotated(-rotation), Color(1, 1, 1), 2)
	#else:
	#	draw_line(ray.position, ray.cast_to.rotated(-rotation), Color(0, 1, 0), 2)

func _input(e):
	if (e is InputEventMouseButton && e.button_index == BUTTON_LEFT && e.pressed) \
		|| e is InputEventScreenTouch && e.pressed:	
		if anchor:
			print("free")
			emit_signal("free")
			anchor == null
			return
		if e is InputEventScreenTouch:
			ray.cast_to = (get_canvas_transform().xform_inv(e.position) -ray.global_position).rotated(-rotation)
		else:		
			# Raycast to position
			ray.cast_to = (e.global_position-ray.global_position).rotated(-rotation)
		#ray.rotation = (e.global_position-ray.global_position).angle() - deg2rad(90)
		#ray.rotation = ray.global_position.angle_to_point(e.global_position)
		# Force update otherwise collision happens next frame
		ray.force_raycast_update()
		if ray.is_colliding():
			print("anchor")
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
	
func init(pos):
	global_position = pos

func _on_Player_body_entered(body):
	if dead: return
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

func _on_swiperDetector_swiped(direction):
	pass
	#if dead or reset: return
#	if direction == Vector2(-1, 0):
#		emit_signal("swipe", "right")
#	elif direction == Vector2(1, 0):
#		emit_signal("swipe", "left")
