extends KinematicBody2D

var gravity = 400
var speed = 800
var velocity = Vector2.ZERO

func _ready():
	pass
	
func _process(delta):
	velocity.x = Input.get_accelerometer().normalized().x * speed

func _physics_process(delta):

	velocity.y += gravity
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
