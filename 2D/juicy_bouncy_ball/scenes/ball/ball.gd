extends CharacterBody2D

signal hit()

@export var bounce_particles: PackedScene = preload("res://bounce_particles.tscn")
@export var speed: float = 400.0
@export var gravity: float = 30.0
@export var sprite_deform_scale: Vector2 = Vector2.ONE

var hitstop_frames: int = 0
var histop_floor: int = 5

var max_speed: float = 25.0

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var base_scale: Vector2 = sprite.scale

func _physics_process(delta):
	if hitstop_frames > 0:
		hitstop_frames -= 1
		if hitstop_frames <= 0:
			stop_hitstop()
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if not animation_player.is_playing():
		# Lerp the scale of the ball based on velocity
		print(velocity.length())
		sprite.scale = lerp(base_scale, base_scale * sprite_deform_scale, velocity.length()/max_speed)

	var collision = move_and_collide(velocity)
	if not collision: return
	velocity = velocity.bounce(collision.get_normal())
	hit.emit()
	animation_player.play("bounce_w_color_w_deform")
	spawn_bounce_particles(collision.get_position(), collision.get_normal().angle())
	Globals.camera.shake(0.45, 30.0, 20.0)
	Input.start_joy_vibration(0, 0.4, 0.2, 0.3)
	start_hitstop(histop_floor)

func spawn_bounce_particles(pos: Vector2, angle: float) -> void:
	var instance = bounce_particles.instantiate()
	get_tree().get_current_scene().add_child(instance)
	instance.global_position = pos
	instance.rotation = angle

func start_hitstop(frames: int) -> void:
	animation_player.pause()
	hitstop_frames = frames

func stop_hitstop() -> void:
	hitstop_frames = 0
	animation_player.play()
