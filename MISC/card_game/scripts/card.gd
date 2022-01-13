extends TextureRect

signal placed()

onready var original_pos = rect_position

var clicked: bool = false
var captured: bool = false
var click_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	rect_pivot_offset = rect_size/2
	
func capture(pos):
	captured = true
#	rect_global_position = pos
	move_to(pos)
	$AnimationPlayer.play("RESET")

func release():
	captured = false
	$Tween.remove_all()
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1.1, 1.1), 
		0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()
	$AnimationPlayer.play("wiggle")
	
func move_to(pos):
	$Tween.remove_all()
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2.ONE, 
		0.35, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_global_position", rect_global_position, pos, 
		0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()

func _on_Card_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			click_pos = event.position
			clicked = true
			$AnimationPlayer.play("wiggle")
		elif !event.pressed && !captured:
			clicked = false
			$AnimationPlayer.play("RESET")
			$Tween.remove_all()
			$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2.ONE, 
				0.35, Tween.TRANS_CUBIC, Tween.EASE_IN)
			$Tween.interpolate_property(self, "rect_position", rect_position, original_pos, 
				0.35, Tween.TRANS_CUBIC, Tween.EASE_IN)
			$Tween.start()
		elif !event.pressed && captured:
			emit_signal("placed")
	if event is InputEventMouseMotion && clicked:
		if captured:
			# Compare the current mouse position from the card position
			var dist = abs((rect_global_position+click_pos).distance_to(get_global_mouse_position()))
			print(dist)
			if dist > 250:
				release()
		else:
			rect_global_position = get_global_mouse_position() - click_pos
#			rect_position += event.relative

func _on_Card_mouse_entered() -> void:
	if captured: return
	$Tween.remove_all()
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(1.1, 1.1), 
		0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rect_position", rect_position, original_pos-Vector2(0, 50), 
		0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()

func _on_Card_mouse_exited() -> void:
	if captured: return
	$Tween.remove_all()
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2.ONE, 
		0.35, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_position", rect_position, original_pos, 
		0.35, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()

func _on_Card_resized() -> void:
	rect_pivot_offset = rect_size/2
