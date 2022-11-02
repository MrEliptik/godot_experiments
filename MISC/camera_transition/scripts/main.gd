extends Node

export var example_2D: PackedScene = preload("res://scenes/2D_example.tscn")
export var example_3D: PackedScene = preload("res://scenes/3D_example.tscn")

func _ready() -> void:
	pass
	
func switch_to_scene(scene: PackedScene) -> void:
	$CurrentScene.get_child(0).queue_free()
	var instance = scene.instance()
	$CurrentScene.add_child(instance)

func _on_HUD_goto_2D() -> void:
	switch_to_scene(example_2D)

func _on_HUD_goto_3D() -> void:
	switch_to_scene(example_3D)

func _on_HUD_transition_simple() -> void:
	var curr_scene = $CurrentScene.get_child(0)
	if $CurrentScene.get_child(0).camera_1.current:
		CameraTransition.switch_camera($CurrentScene.get_child(0).camera_1, $CurrentScene.get_child(0).camera_2)
	else:
		CameraTransition.switch_camera($CurrentScene.get_child(0).camera_2, $CurrentScene.get_child(0).camera_1)

func _on_HUD_transition_smooth() -> void:
	var curr_scene = $CurrentScene.get_child(0)
	if curr_scene.name == "2DExample":
		if $CurrentScene.get_child(0).camera_1.current:
			CameraTransition.transition_camera2D($CurrentScene.get_child(0).camera_1, $CurrentScene.get_child(0).camera_2, 2.0)
		else:
			CameraTransition.transition_camera2D($CurrentScene.get_child(0).camera_2, $CurrentScene.get_child(0).camera_1, 2.0)
	else:
		if $CurrentScene.get_child(0).camera_1.current:
			CameraTransition.transition_camera3D($CurrentScene.get_child(0).camera_1, $CurrentScene.get_child(0).camera_2, 2.0)
		else:
			CameraTransition.transition_camera3D($CurrentScene.get_child(0).camera_2, $CurrentScene.get_child(0).camera_1, 2.0)
			
