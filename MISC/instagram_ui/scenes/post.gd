extends Control

signal like()

export var heart_full: StreamTexture
export var heart: StreamTexture

onready var like_btn = $Content/VBoxContainer/ButtonContainer/LikeBtn

var double_click_delay: float = 500.0 # in ms, the same as default Windows delay
var first_click = false
var liked = false
var timeout = true

func _ready():
	$Timer.wait_time = (double_click_delay/1000.0)
	
func like(toggle=false):
	if liked && toggle:
		liked = false
		like_btn.texture_normal = heart
	else:
		liked = true
		emit_signal("like")
		$Content/TextureRect/Heart.modulate = Color("#ffffff")
		$Tween.interpolate_property($Content/TextureRect/Heart, "rect_scale", 
			Vector2.ZERO, Vector2(2, 2), 0.7, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		like_btn.texture_normal = heart_full
	#	$Tween.interpolate_property($Content/VBoxContainer/ButtonContainer/LikeBtn, 
	#		"rect_scale", Vector2.ONE, Vector2.ZERO, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.start()

func _on_LikeBtn_pressed():
	like(true)

func _on_Tween_tween_completed(object, key):
	if object == $Content/TextureRect/Heart && key == ":rect_scale":
		$Tween.interpolate_property($Content/TextureRect/Heart, "modulate", 
			Color("#ffffff"), Color("#00ffffff"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
	
	if object == like_btn && key == ":rect_scale" && like_btn.rect_scale == Vector2.ZERO:
		$Tween.interpolate_property($Content/VBoxContainer/ButtonContainer/LikeBtn, 
			"rect_scale", Vector2.ONE, Vector2.ZERO, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		
func _on_TextureRect_gui_input(event):
	if !event is InputEventMouseButton: return
	if event.button_index != BUTTON_LEFT: return
	if !event.is_pressed():
		if !first_click: 
			first_click = true
			$Timer.start()
			timeout = false
		elif !timeout: 
			like()
			first_click = false
			timeout = false

func _on_Timer_timeout():
	timeout = true
	first_click = false
