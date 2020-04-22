extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_right_index_pinch(val):
	if val: $Viewport/Control/VBoxContainer/HBoxContainer2/HBoxContainer/VBoxContainer/ColorRect.color = Color('4e9e23')
	else: $Viewport/Control/VBoxContainer/HBoxContainer2/HBoxContainer/VBoxContainer/ColorRect.color = Color('9e2323')

func set_right_middle_pinch(val):
	if val: $Viewport/Control/VBoxContainer/HBoxContainer2/HBoxContainer2/VBoxContainer/ColorRect.color = Color('4e9e23')
	else: $Viewport/Control/VBoxContainer/HBoxContainer2/HBoxContainer2/VBoxContainer/ColorRect.color = Color('9e2323')
	
func set_right_pinky_pinch(val):
	if val: $Viewport/Control/VBoxContainer/HBoxContainer2/HBoxContainer3/VBoxContainer/ColorRect.color = Color('4e9e23')
	else: $Viewport/Control/VBoxContainer/HBoxContainer2/HBoxContainer3/VBoxContainer/ColorRect.color = Color('9e2323')
	
func set_right_ring_pinch(val):
	if val: $Viewport/Control/VBoxContainer/HBoxContainer2/HBoxContainer4/VBoxContainer/ColorRect.color = Color('4e9e23')
	else: $Viewport/Control/VBoxContainer/HBoxContainer2/HBoxContainer4/VBoxContainer/ColorRect.color = Color('9e2323')
	
func set_left_index_pinch(val):
	if val: $Viewport/Control/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/ColorRect.color = Color('4e9e23')
	else: $Viewport/Control/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/ColorRect.color = Color('9e2323')
	
func set_left_middle_pinch(val):
	if val: $Viewport/Control/VBoxContainer/HBoxContainer/HBoxContainer2/VBoxContainer/ColorRect.color = Color('4e9e23')
	else: $Viewport/Control/VBoxContainer/HBoxContainer/HBoxContainer2/VBoxContainer/ColorRect.color = Color('9e2323')
	
func set_left_pinky_pinch(val):
	if val: $Viewport/Control/VBoxContainer/HBoxContainer/HBoxContainer3/VBoxContainer/ColorRect.color = Color('4e9e23')
	else: $Viewport/Control/VBoxContainer/HBoxContainer/HBoxContainer3/VBoxContainer/ColorRect.color = Color('9e2323')
	
func set_left_ring_pinch(val):
	if val: $Viewport/Control/VBoxContainer/HBoxContainer/HBoxContainer4/VBoxContainer/ColorRect.color = Color('4e9e23')
	else: $Viewport/Control/VBoxContainer/HBoxContainer/HBoxContainer4/VBoxContainer/ColorRect.color = Color('9e2323')
	
