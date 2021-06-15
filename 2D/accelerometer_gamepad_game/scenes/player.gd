extends KinematicBody2D

var bullet = preload("res://scenes/bullet.tscn")

var velocity = Vector2.ZERO
var speed = 1200.0

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		fire()
	
func _physics_process(delta):
	move_and_collide(velocity * delta)

func move(dir):
	velocity.x = dir * speed
	
func fire():
	var instance = bullet.instance()
	get_parent().add_child(instance)
	instance.global_position = $Position2D.global_position
