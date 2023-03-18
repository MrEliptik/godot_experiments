extends Node2D

@export var spring: float = 150.0
@export var damp: float = 10.0
@export var multiplier: float = 25.0

var displacement: float = 0.0 
var velocity: float = 0.0

func _ready():
	pass # Replace with function body.

func _process(delta):
	var force = -spring * displacement + damp * velocity
	velocity -= force * delta
	displacement -= velocity * delta
	
	rotation = displacement

func _on_area_2d_body_entered(body):
	velocity = body.velocity.normalized().x * multiplier
