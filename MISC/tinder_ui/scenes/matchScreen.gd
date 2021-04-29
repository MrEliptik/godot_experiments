extends Control

signal keep_swiping()

func _ready():
	$Tween.interpolate_property($MarginContainer/MatchText, "rect_scale",
		Vector2(2.5, 2.5), Vector2.ONE, 0.4, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.start()
	
func set_image(im):
	$Image.texture = im

func _on_KeepSwiping_pressed():
	emit_signal("keep_swiping")
