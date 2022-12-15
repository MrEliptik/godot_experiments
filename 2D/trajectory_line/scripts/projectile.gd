extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2.ZERO
var speed: float = 1200.0
var gravity: float = 1000.0

func _ready() -> void:
	velocity = dir * speed
	
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	var collision = move_and_collide(velocity * delta)
	if not collision: return

	velocity = velocity.bounce(collision.normal) * 0.6
