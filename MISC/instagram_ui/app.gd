extends Control

export var home: PackedScene = preload("res://scenes/home.tscn")
export var profile: PackedScene = preload("res://scenes/profile.tscn")

func _ready():
	$BottomPanel/HomeBtn.pressed = true 

func switch_scene(new_scene):
	$CurrentView.remove_child($CurrentView.get_child(0))
	var instance = new_scene.instance()
	$CurrentView.add_child(instance)
	
	$BottomPanel/HomeBtn.pressed = false
	$BottomPanel/MarginContainer/ProfileBtn.pressed = false
	if new_scene == home:
		$BottomPanel/HomeBtn.pressed = true
	elif new_scene == profile:
		$BottomPanel/MarginContainer/ProfileBtn.pressed = true

func _on_HomeBtn_pressed():
	switch_scene(home)

func _on_SearchBtn_pressed():
	pass # Replace with function body.

func _on_VideoBtn_pressed():
	pass # Replace with function body.

func _on_ShopBtn_pressed():
	pass # Replace with function body.

func _on_ProfilBtn_pressed():
	switch_scene(profile)
