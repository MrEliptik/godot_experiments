extends KinematicBody2D

export var bullet: PackedScene = preload("res://scenes/bullet.tscn")
export var missile: PackedScene = preload("res://scenes/homingMissile.tscn")
export var muzzle_flash: PackedScene = preload("res://scenes/muzzleFlash.tscn")


var speed := 500.0

var velocity := Vector2.ZERO
var dir := Vector2.ZERO

var accel := 0.1
var deccel := 0.25

var rotation_speed := 0.2

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	# Camera offset
	var mouse_pos = get_global_mouse_position()
	$Camera2D.offset_h = (mouse_pos.x - global_position.x) / (1920.0 / 2.0)
	$Camera2D.offset_v = (mouse_pos.y - global_position.y) / (1080.0 / 2.0)
	
	# get vector from player to mouse
	var v = get_global_mouse_position() - global_position
	
	# get angle from that vector
	var angle = v.angle()
	
	global_rotation = lerp_angle(global_rotation, angle, rotation_speed)
#	look_at(get_global_mouse_position())
	
	var dir_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var dir_y = Input.get_action_strength("back") - Input.get_action_strength("front")
	
#	velocity.y = dir_y * speed
#	velocity.x = dir_x * speed
	
	# Lerped
	if dir_x != 0 or dir_y != 0:
		velocity.y = lerp(velocity.y, dir_y * speed, accel)
		velocity.x = lerp(velocity.x, dir_x * speed, accel)
	else:
		velocity.y = lerp(velocity.y, 0, deccel)
		velocity.x = lerp(velocity.x, 0, deccel)
		
	velocity = velocity.clamped(speed)
	
	if Input.is_action_just_pressed("shoot"):
		$Camera2D.shake(0.25, 25, 8)
		var inst = muzzle_flash.instance()
		inst.position = $MuzzlePos.position
		call_deferred("add_child", inst)
		
		var instance = bullet.instance()
		instance.global_transform = $BulletPos.global_transform
		get_parent().call_deferred("add_child", instance)
	
	if Input.is_action_just_pressed("shoot_missile"):
		$Camera2D.shake(0.3, 30, 12)
		var inst = muzzle_flash.instance()
		inst.position = $MuzzlePos.position
		call_deferred("add_child", inst)
		
		var instance = missile.instance()
		instance.global_transform = $BulletPos.global_transform
		
		var min_dist := 100000.0
		var selected_target = null
		for enemy in get_parent().get_node("Enemies").get_children():
			var dist = global_position.distance_to(enemy.global_position)
			if dist < min_dist:
				selected_target = enemy
		instance.target = get_global_mouse_position()
		get_parent().call_deferred("add_child", instance)
	
func _physics_process(delta: float) -> void:
	
	velocity = move_and_slide(velocity)
	
	var collision_count = get_slide_count()
	for i in collision_count:
		var collision = get_slide_collision(i)
		$Camera2D.shake(0.2, 25, 5)
