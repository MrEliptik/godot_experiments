extends Control

signal moving()
signal finished()

export var image1: StreamTexture
export var image2: StreamTexture
export var image3: StreamTexture
export var image4: StreamTexture
export var image5: StreamTexture

onready var images = [image1, image2, image3, image4, image5]

var image_idx = 0

var pressed = false
var first_press_pos = null
var latest_speed = Vector2.ZERO

var nope_like_visible_dist = 450

var enabled = false

func _ready():
	randomize()
	var images_temp = []
	for image in images:
		if image:
			images_temp.append(image)
	images = images_temp
	images.shuffle()
	change_image(0)
	
func _input(event):
	if !enabled: return
	if event is InputEventScreenDrag:
		var dist = event.position - first_press_pos
		emit_signal("moving")
		rect_position = dist
		rect_rotation = -(event.position.x - first_press_pos.x) * 0.025
		if sign(dist.x) > 0: 
			$Like.modulate = lerp(Color("#00ffffff"), Color("#ffffffff"), abs(dist.x)/nope_like_visible_dist)
		else:
			$Nope.modulate = lerp(Color("#00ffffff"), Color("#ffffffff"), abs(dist.x)/nope_like_visible_dist)
		pressed = false
		latest_speed = event.speed
	if event is InputEventMouseButton:
		if event.pressed:
			pressed = true
			first_press_pos = event.position
		else:
			if pressed:
				if event.position.x > (rect_size.x/2):
					_on_NextBtn_pressed()
				else:
					_on_PreviousBtn_pressed()
			else:
				pressed = false
				first_press_pos = null
				if abs(latest_speed.x) > 1300:
					# remove card
					rect_position += latest_speed
					emit_signal("finished")
					queue_free()
				else:
					rect_position = Vector2.ZERO
					rect_rotation = 0
					$Like.modulate = Color("#00ffffff")
					$Nope.modulate = Color("#00ffffff")
	
func change_image(idx):
	$ScrollContainer/VBoxContainer/Image.texture = images[idx]

func _on_PreviousBtn_pressed():
	if image_idx == 0: image_idx = images.size() - 1
	else: image_idx -= 1
	change_image(image_idx)

func _on_NextBtn_pressed():
	if image_idx == images.size() - 1: image_idx = 0
	else: image_idx += 1
	change_image(image_idx)

func _on_Card_gui_input(event):
	pass
