extends Control

signal play()
signal speed_up()
signal slow_down()

onready var slow_btn = $HBoxContainer2/HBoxContainer/SlowBtn
onready var speed_btn = $HBoxContainer2/HBoxContainer/SpeedBtn
onready var speed_label = $HBoxContainer2/HBoxContainer/SpeedLabel

onready var play_btn = $HBoxContainer2/PlayBtn

var time_scale = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_SlowBtn_pressed():
	time_scale -= 0.25
	emit_signal("slow_down")
	speed_label.text = str(time_scale)

func _on_SpeedBtn_pressed():
	time_scale += 0.25
	emit_signal("speed_up")
	speed_label.text = str(time_scale)

func _on_PlayBtn_pressed():
	emit_signal("play")
