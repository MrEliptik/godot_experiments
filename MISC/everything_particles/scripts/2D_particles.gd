extends Node2D

var texts = ["HELLO", "PI", "COOL", "WHAT"]

func _ready() -> void:
	randomize()
	$Timer.start(rand_range(0.1, 1.5))


func _on_Timer_timeout() -> void:
	$Viewport/Label.text = texts[randi() % texts.size()]
	$Timer.start(rand_range(2, 5))


func _on_VideoPlayer_finished() -> void:
	$Viewport2/VideoPlayer.play()
