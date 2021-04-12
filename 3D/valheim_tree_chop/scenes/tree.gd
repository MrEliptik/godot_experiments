extends Node

export var next_scene: PackedScene = preload("res://scenes/tree/treeTrunk.tscn")
export var health: int = 4
export var impulse_force: float = 150.0
export var impulse_direction: Vector3 = Vector3(.0, 1.0, .0)
export var origin_offset: Vector3

func _ready():
	randomize() 

func take_damage(damage):
	if health <= 0: return
	health -= damage
	if health <= 0:
		die()
		
func die():
	var instance = next_scene.instance()
	get_parent().add_child(instance)
	instance.global_transform.origin = $SpawnPoint.global_transform.origin + origin_offset
	print(instance.global_transform.basis)
	print(impulse_direction)
	print(instance.global_transform.basis * impulse_direction)
	instance.apply_central_impulse(
		(instance.global_transform.basis * impulse_direction) * impulse_force
	)
