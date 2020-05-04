extends Control

const play = preload("res://medias/ui/play.png")
const pause = preload("res://medias/ui/pause.png")
const replay = preload("res://medias/ui/restart.png")

onready var videoplayer = $VBoxContainer/VBoxContainer4/MarginContainer/VideoPlayer
onready var video_playback_btn = $VBoxContainer/VBoxContainer4/MarginContainer/TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
