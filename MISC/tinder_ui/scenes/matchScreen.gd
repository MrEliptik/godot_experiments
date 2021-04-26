extends Control

signal keep_swiping()

func _ready():
	pass
	
func set_image(im):
	$Image.texture = im

func _on_KeepSwiping_pressed():
	emit_signal("keep_swiping")
