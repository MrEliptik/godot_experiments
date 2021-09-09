extends KinematicBody2D

export var blood: PackedScene = preload("res://scenes/bloodSplat.tscn")

var speed := 150.0
var player = null
var accel := 0.1

var velocity := Vector2.ZERO

func _ready() -> void:
	randomize()
	speed += rand_range(-50, 50)

func _physics_process(delta: float) -> void:
	if !player: return
	
	look_at(player.global_position)
	
	var dir = (player.global_position - global_position).normalized()
	velocity = lerp(velocity, speed * dir, accel)
	
	velocity = move_and_slide(velocity)
	
func set_player(p):
	player = p
	
func die():
	var instance = blood.instance()
	instance.global_transform = global_transform
	get_parent().get_parent().call_deferred("add_child", instance)
	call_deferred("queue_free")
	
	
