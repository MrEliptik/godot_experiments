extends Control

const play = preload("res://medias/ui/play.png")
const pause = preload("res://medias/ui/pause.png")
const replay = preload("res://medias/ui/restart.png")
const icon = preload("res://godot.png")

onready var videoplayer = $VBoxContainer/VBoxContainer4/MarginContainer/VideoPlayer
onready var video_playback_btn = $VBoxContainer/VBoxContainer4/MarginContainer/TextureRect
onready var item_list = $VBoxContainer/ItemList
onready var slider_value = $VBoxContainer/Value
onready var progress_bar = $VBoxContainer/VBoxContainer2/GridContainer/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(30):
		item_list.add_icon_item(icon)

func _on_VideoPlayer_gui_input(event):
	print(event)
	# Touch release
	if event is InputEventScreenTouch and not event.is_pressed():
		if videoplayer.is_playing():
			# Toggle pause/play
			videoplayer.paused = !videoplayer.paused
			if videoplayer.paused: video_playback_btn.texture = pause
			else: video_playback_btn.texture = null
		else: 
			videoplayer.play()
			video_playback_btn.texture = null

func _on_VideoPlayer_finished():
	video_playback_btn.texture = replay

func _on_value_changed(value):
	slider_value.text = str(value)
	progress_bar.value = value
