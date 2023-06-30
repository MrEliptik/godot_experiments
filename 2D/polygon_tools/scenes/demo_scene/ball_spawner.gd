extends Node

@export var ball_scene: PackedScene = preload("res://scenes/ball/ball.tscn")

@onready var parent: Node2D = get_parent()

func start() -> void:
	$Timer.start()

func spawn_ball() -> void:
	var instance = ball_scene.instantiate()
	parent.call_deferred("add_child", instance)
	await instance.ready
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	instance.global_position = Vector2(randf_range(0, viewport_size.x), -150.0)

func _on_timer_timeout():
	spawn_ball()
