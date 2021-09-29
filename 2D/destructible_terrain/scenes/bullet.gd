extends Node2D

export var particles: PackedScene = preload("res://scenes/explosionParticles.tscn")
export var radius = 100.0
export var explosion_force = 350.0

var velocity := Vector2.ZERO
var gravity := 0.0

var collider = null

var affected = []

func _ready() -> void:
	randomize()
	var nb_points = 32
	var points = PoolVector2Array()
	for i in range(nb_points+1):
		var point = deg2rad(i * 360.0 / nb_points - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * radius)
	$Area2D/DestructionPolygon.polygon = points
	
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
	rotation = velocity.angle()
	
func explode() -> void:
	for x in affected:
#		x.apply_central_impulse((Vector2.UP * explosion_force).rotated(rand_range(-10, 10)))
		x.apply_central_impulse((x.global_position - global_position).normalized() * explosion_force)
	var inst = particles.instance()
	inst.global_position = global_position
	get_parent().call_deferred("add_child", inst)
	
	if collider.is_in_group("Destructibles"):
		collider.get_parent().clip($Area2D/DestructionPolygon)
	call_deferred("queue_free")
	
func _on_CollisionDetection_body_entered(body: Node) -> void:
	if body.is_in_group("Player"): return
	collider = body
	explode()

func _on_Area2D_body_entered(body: Node) -> void:
	if !body.is_in_group("Worms"): return
	affected.append(body)

func _on_Area2D_body_exited(body: Node) -> void:
	if !body.is_in_group("Worms"): return
	affected.erase(body)
