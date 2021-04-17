extends Control

onready var first_scroll = $VBoxContainer/ScrollContainer
onready var second_scroll = $VBoxContainer/ScrollContainer/VBoxContainer2/VBoxContainer/ScrollContainer2
onready var first_content = $VBoxContainer/ScrollContainer/VBoxContainer2/FirstScrollContent

var scrolling_up = false

func _ready():
	pass 
	
func _input(event):
	#print(event)
	if event is InputEventPanGesture:
		print(sign(event.delta.y))
		if sign(event.delta.y) > 0:
			scrolling_up = true
			
	elif event is InputEventMouseButton:
		print(event.button_index)
		if event.button_index == BUTTON_WHEEL_UP:
			scrolling_up = true
		#BUTTON_WHEEL_UP  

func _process(delta):
	#print(first_scroll.scroll_vertical)
	#print(second_scroll.scroll_vertical)
	print(scrolling_up)
	if second_scroll.scroll_vertical == 0 && scrolling_up:
		first_content.visible = true
		second_scroll.scroll_vertical_enabled = false
	elif first_scroll.scroll_vertical >= 1080 && first_content.visible:
		first_scroll.scroll_vertical = 1080
		first_content.visible = false
		second_scroll.scroll_vertical_enabled = true
	
	scrolling_up = false
		#$VBoxContainer/ScrollContainer/VBoxContainer2/FirstScrollContent/HighlightsContainer/HBoxContainer2/VBoxContainer/StoryBtn.grab_focus()
