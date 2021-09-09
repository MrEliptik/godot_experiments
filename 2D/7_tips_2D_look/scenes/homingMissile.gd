extends Area2D

export var explosion: PackedScene = preload("res://scenes/explosionParticles.tscn")

export var speed = 500
export var steer_force = 40.0

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

var inside_destruction = []

func _ready() -> void:
	rotation_degrees += rand_range(-35, 35)
	velocity = transform.x * speed 
	
func _physics_process(delta: float) -> void:
	if !target: return
	
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	position += velocity * delta

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired
		if target is Vector2:
			desired = (target - position).normalized() * speed
		else:
			desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer
	
func die():
	var instance = explosion.instance()
	instance.global_transform = global_transform
	get_parent().call_deferred("add_child", instance)
	
	for x in inside_destruction:
		if !x.has_method("die"): continue
		x.die()
	
	call_deferred("queue_free")

func _on_HomingMissile_body_entered(body: Node) -> void:
	die()

func _on_Timer_timeout() -> void:
	die()

func _on_Destruction_body_entered(body: Node) -> void:
	inside_destruction.append(body)

func _on_Destruction_body_exited(body: Node) -> void:
	inside_destruction.erase(body)
