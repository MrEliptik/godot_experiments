extends Node2D

const SPEED = 100

onready var wall = $Sprite

var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if !moving: return
	wall.position.x += delta*SPEED
