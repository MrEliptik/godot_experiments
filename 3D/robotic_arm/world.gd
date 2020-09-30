extends Spatial

const object = preload("res://object.tscn")

export var object_number = 10000
export var spawn_time_interval = 1.0

onready var objects = $Room/Objects

var spawned_number = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_SpawnIntervalTimer_timeout():
	if spawned_number == object_number:
		$SpawnIntervalTimer.stop()
	else:
		# Spawn an object at the spawn location
		var instance = object.instance()
		instance.global_transform = $Room/Spawner/SpawnPoint.global_transform
		# TODO: Choose a color
		
		objects.add_child(instance)
		spawned_number += 1
