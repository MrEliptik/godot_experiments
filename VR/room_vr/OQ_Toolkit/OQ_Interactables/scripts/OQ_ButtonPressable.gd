# This is a first draft of a pressable toggle button
# At the moment it interacts with any area that enters it

extends Spatial

signal button_pressed

var touching := false
var at_default_pos := true
var triggering := false
var is_on := false
var hand_area: Area
var button_half_length_vector
var hand_pos: Vector3
var prev_hand_pos: Vector3
var dist := 0.0
var lerp_weight: float
var start_time := 0.0
var speed := 2.0

onready var initial_pos_local: = get_transform().origin
onready var initial_pos_global: = get_global_transform().origin
onready var button_forward_vector_norm = get_transform().basis.z.normalized()
onready var z_scale = scale.z
onready var button_mesh := $MeshInstance

export var press_distance := 0.008
export(Material) var off_material
export(Material) var on_material
export var on_on_start := false


func _ready():
	# connect to signals
	$ButtonArea.connect("area_entered", self, "_on_ButtonArea_area_entered")
	$ButtonArea.connect("area_exited", self, "_on_ButtonArea_area_exited")
	
	button_half_length_vector = initial_pos_local + button_forward_vector_norm * z_scale / 2
	
	# switch to correct material
	if (on_on_start):
		is_on = true
	switch_mat(is_on)


func _process(delta):
	
	if touching:
		# if hand is touching the button, we need to know how far in it is pressed
		
		# check how much hand pos has changed in buttons local z direction
		hand_pos = hand_area.global_transform.origin
		var hand_pos_change = hand_pos - prev_hand_pos
		
		var hand_pos_change_z_component = hand_pos_change.slide(button_forward_vector_norm)
		dist = hand_pos_change_z_component.length()
		var new_origin = Vector3(initial_pos_local.x, initial_pos_local.y, transform.origin.z - dist)
		
		# only keep pushing back until press_distance is reached
		if initial_pos_local.z - new_origin.z < press_distance:
			transform.origin = new_origin
		elif !triggering:
			# trigger button press
			triggering = true
			button_press(hand_area)
		
		prev_hand_pos = hand_pos

	elif !at_default_pos:
		# if not touching and not at default pos, bring back to default pos
		lerp_weight = start_time / speed
		var move_by = lerp(dist, 0, lerp_weight)
		
		var new_origin = Vector3(initial_pos_local.x, initial_pos_local.y, initial_pos_local.z + move_by)
		
		transform.origin = new_origin
		
		start_time += delta
		
		if lerp_weight > 0:
			start_time = 0.0
			at_default_pos = true
			triggering = false
		


func _on_ButtonArea_area_entered(area):
	touching = true
	at_default_pos = false
	hand_area = area
	
	hand_pos = hand_area.global_transform.origin
	prev_hand_pos = hand_area.global_transform.origin


func _on_ButtonArea_area_exited(_area):
	touching = false


func button_press(_other_area: Area):
	is_on = !is_on
	switch_mat(is_on)
	emit_signal("button_pressed")


func switch_mat(_is_on):
	if _is_on:
		button_mesh.set_material_override(on_material)
	else:
		button_mesh.set_material_override(off_material)
