extends Control

signal moving()
signal finished()
signal like(card, image)
signal dislike(card)

export var image1: StreamTexture
export var image2: StreamTexture
export var image3: StreamTexture

export var image4: StreamTexture
export var image5: StreamTexture
export var image6: StreamTexture

export var image7: StreamTexture
export var image8: StreamTexture
export var image9: StreamTexture

onready var images_set1 = [image1, image2, image3]
onready var images_set2 = [image4, image5, image6]
onready var images_set3 = [image7, image8, image9]
onready var sets = [images_set1, images_set2, images_set3]

var image_idx = 0

var pressed = false
var first_press_pos = null
var latest_speed = Vector2.ZERO

var nope_like_visible_dist = 450

var enabled = false

var name_age_arr = ["John, 22", "Gabriella, 100", "Ipo, 33"]
var images = []

func _ready():
	randomize()
	# Choose random image set
	images = sets[int(rand_range(0, 3))]
	
	change_image(0)
	
	## Choose random name
	$Button/MarginContainer/HBoxContainer/VBoxContainer/NameAge.text = name_age_arr[int(rand_range(0, name_age_arr.size()))]
	
	$ImageContainer/Image.material.set_shader_param("size", $ImageContainer/Image.rect_size)
	
func _input(event):
	if !enabled: return
	if event is InputEventScreenDrag:
		var dist = event.position - first_press_pos
		emit_signal("moving")
		rect_position = dist
		rect_rotation = -(event.position.x - first_press_pos.x) * 0.025
		if sign(dist.x) > 0: 
			$Like.modulate = lerp(Color("#00ffffff"), Color("#ffffffff"), 
				abs(dist.x)/nope_like_visible_dist)
		else:
			$Nope.modulate = lerp(Color("#00ffffff"), Color("#ffffffff"), 
				abs(dist.x)/nope_like_visible_dist)
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
				if abs(latest_speed.x) > 1000:
					# remove card
					rect_position += latest_speed
					emit_signal("finished")
					if sign(latest_speed.x) > 0:
						emit_signal("like", self, $ImageContainer/Image.texture)
					else:
						emit_signal("dislike", self)
					queue_free()
				else:
					rect_position = Vector2.ZERO
					rect_rotation = 0
					$Like.modulate = Color("#00ffffff")
					$Nope.modulate = Color("#00ffffff")
	
	
func change_image(idx):
	for child in $MarginContainer/HBoxContainer.get_children():
		child.value = 0
	$ImageContainer/Image.texture = images[idx]
	$MarginContainer/HBoxContainer.get_child(idx).value = 100

func _on_PreviousBtn_pressed():
	if image_idx == 0: image_idx = images.size() - 1
	else: image_idx -= 1
	change_image(image_idx)

func _on_NextBtn_pressed():
	if image_idx == images.size() - 1: image_idx = 0
	else: image_idx += 1
	change_image(image_idx)

func _on_Card_gui_input(event):
	print(event)

func _on_Button_pressed():
	pass # Replace with function body.
