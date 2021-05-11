extends KinematicBody2D

var speed = 100
var vel = Vector2.ZERO
var dir = Vector2.LEFT

var slow_factor = 1.0
var timer_wait_time = 2

func _ready():
	vel = dir * speed

func _physics_process(delta):
	var col = move_and_collide(vel * delta * slow_factor)
	if col:
		vel = vel.bounce(col.normal)

func slow_down(val: bool, factor: float):
	slow_factor = factor
