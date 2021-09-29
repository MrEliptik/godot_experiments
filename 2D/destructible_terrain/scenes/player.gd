extends RigidBody2D

export var bullet: PackedScene = preload("res://scenes/bullet.tscn")

var gravity := 400.0
var speed := 1500.0
var velocity := Vector2.ZERO
var bullet_velocity := 600.0
var jump_force := 300.0

func _ready() -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.is_pressed(): return
		if event.button_index == BUTTON_WHEEL_UP:
			bullet_velocity += 20
			bullet_velocity = clamp(bullet_velocity, 100, 1500)
		if event.button_index == BUTTON_WHEEL_DOWN:
			bullet_velocity -= 20
			bullet_velocity = clamp(bullet_velocity, 100, 1500)

func _process(delta: float) -> void:
	$RotPoint.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot"):
		var b = bullet.instance()
		get_parent().add_child(b)
		b.transform = $RotPoint/ShootPoint.global_transform
		b.velocity = b.transform.x * bullet_velocity
		b.gravity = gravity
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		apply_central_impulse(-global_transform.x * speed * delta)
	elif Input.is_action_pressed("right"):
		apply_central_impulse(global_transform.x * speed * delta)
	elif Input.is_action_just_pressed("jump"):
		apply_central_impulse(Vector2.UP * jump_force)
