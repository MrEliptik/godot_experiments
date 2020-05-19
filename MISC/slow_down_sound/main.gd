extends Control

var slow = false

onready var pitch_tween = music.get_node("PitchTween")
onready var volume_tween = music.get_node("VolumeTween")
onready var music_player = music.get_node("AudioStreamPlayer")
onready var btn_label = $VBoxContainer/HBoxContainer/Button
onready var pitch_label = $VBoxContainer/HBoxContainer2/PitchScale
onready var volume_label = $VBoxContainer/HBoxContainer2/Volume

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	pitch_label.text = str(stepify(music_player.pitch_scale, 0.01))
	volume_label.text = str(stepify(music_player.volume_db, 0.01))


func _on_Button_pressed():
	if !slow:
		btn_label.text = "Speed up"
		pitch_tween.interpolate_property(music_player, "pitch_scale", 1.0, 0.7, 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		pitch_tween.start()
		volume_tween.interpolate_property(music_player, "volume_db", 0.0, -13.0, 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		volume_tween.start()
		slow = true
	else:
		btn_label.text = "Slow down"
		pitch_tween.interpolate_property(music_player, "pitch_scale", 0.7, 1.0, 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		pitch_tween.start()
		volume_tween.interpolate_property(music_player, "volume_db", -13.0, 0.0, 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		volume_tween.start()
		slow = false
