extends Node2D

export var enemy: PackedScene = preload("res://scenes/enemy.tscn")

func _ready() -> void:
	randomize()
	for enemy in $Enemies.get_children():
		enemy.set_player($Player)
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_Timer_timeout() -> void:
	var instance = enemy.instance()
	var idx = int(rand_range(0, $SpawnPoint.get_child_count() - 1))
	instance.global_transform = $SpawnPoint.get_child(idx).global_transform
	instance.set_player($Player)
	$Enemies.call_deferred("add_child", instance)
	$Timer.start(rand_range(0.2, 2.0))
