extends Spatial

var tv_video = preload("res://room_Video.tscn")
var tv_animatedTexture = preload("res://room_AnimatedTexture.tscn")
var tv_shader = preload("res://room_TvShader.tscn")

var curr_scene_idx = 0
var scenes = [tv_animatedTexture, tv_video, tv_shader]
var scenes_names = ['AnimatedTexture', 'Video', 'TV shader (video)']

onready var room_container = $RoomContainer

func deload():
	room_container.remove_child(room_container.get_child(0))
	
func load_scene(scene):
	room_container.add_child(scene.instance())

func _on_hud_next():
	if curr_scene_idx < 2:
		curr_scene_idx += 1
		deload()
		load_scene(scenes[curr_scene_idx])
		$hud.set_scene_name(scenes_names[curr_scene_idx])


func _on_hud_previous():
	if curr_scene_idx > 0:
		curr_scene_idx -= 1
		deload()
		load_scene(scenes[curr_scene_idx])
		$hud.set_scene_name(scenes_names[curr_scene_idx])
