extends Control

onready var first_scroll = $VBoxContainer/ScrollContainer
onready var second_scroll = $VBoxContainer/ScrollContainer/VBoxContainer2/VBoxContainer/ScrollContainer2
onready var first_content = $VBoxContainer/ScrollContainer/VBoxContainer2/FirstScrollContent

var scrolling_up = false

func _ready():
	pass 
	
func _input(event):
	if event is InputEventScreenDrag:
		if sign(event.speed.y) > 0:
			scrolling_up = true

	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			scrolling_up = true

func _process(delta):
	if first_scroll.scroll_vertical > 1080 && first_content.visible:
		first_scroll.scroll_vertical = 1080
		first_content.visible = false
		second_scroll.scroll_vertical_enabled = true
	
	elif scrolling_up && second_scroll.scroll_vertical == 0 && !first_content.visible:
		first_content.visible = true
		second_scroll.scroll_vertical_enabled = false
	
	scrolling_up = false
