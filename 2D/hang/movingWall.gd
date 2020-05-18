extends StaticBody2D

export var SPEED = 100

var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if !moving: return
	position.x += delta*SPEED

func reset():
	moving = false
	position = Vector2(0, 0)
