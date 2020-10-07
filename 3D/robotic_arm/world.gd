extends Spatial

const object = preload("res://object.tscn")
const Detector = preload("res://tools/detection.gd")

const MAX_FOV = 96
const MIN_FOV = 33

export var object_number = 10000
export var spawn_time_interval = 1.0
export var reference_color = Color("#fc1b04") 
export var color_tolerance = 4.5

onready var objects = $Room/Things/Objects
onready var reference_obj = $Room/Things/Reference/ReferenceObject
onready var arm = $Room/Robotic_arm

# Camera zoom & rotation
var mouse_sens = 0.15
var zoom_sens = 3
var middle_button_clicked = false

# Object colors
var colors = [Color("#0C96BE"), Color("B023DD"), Color("857f10"), Color("#00FE3A")]
var spawned_number = 0

# CV & arm
onready var detector = Detector.new()
onready var cv_camera = $Room/Viewport/CVCamera
onready var cv_viewport = $Room/Viewport
var blobs = null
var target = null
#var target_grabbed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	arm.set_positions($Room/RestPosition, $Room/DropPosition)
	arm.set_cv_camera(cv_camera)
	
	reference_obj.get_surface_material(0).albedo_color = reference_color
	$CanvasLayer/VBoxContainer/ColorPickerButton.color = reference_color
	
	colors.append(reference_color)

func _unhandled_input(event):
	if event is InputEventMouseButton:

		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				$CameraRotationPoint/Camera.fov -= zoom_sens
				if $CameraRotationPoint/Camera.fov < MIN_FOV: $CameraRotationPoint/Camera.fov = MIN_FOV
			
			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				$CameraRotationPoint/Camera.fov += zoom_sens
				if $CameraRotationPoint/Camera.fov > MAX_FOV: $CameraRotationPoint/Camera.fov = MAX_FOV
			
		if event.button_index == 3:
			if event.is_pressed():
				middle_button_clicked = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				middle_button_clicked = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				
				
	if event is InputEventMouseMotion:
		if !middle_button_clicked: return
		$CameraRotationPoint.rotate_y(deg2rad(-event.relative.x*mouse_sens))
		var changev=-event.relative.y*mouse_sens

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CanvasLayer/FPS.text = "FPS: "+ str(Engine.get_frames_per_second())
	
	# Get previous frame result
	var compute_data = $ComputeViewport.get_texture().get_data()
	blobs = detector.detectColorBlob(compute_data, Color(1.0, 1.0, 1.0, 1.0))
	
	if !blobs.empty():
		var point = blobs[0].center()
		target = point
	else:
		target = null
		
	arm.move_arm(target)
	
	var data = cv_viewport.get_texture().get_data()
	
	# Test with shader
	var text = ImageTexture.new()
	text.create_from_image(data)
	$CanvasLayer/VBoxContainer2/VBoxContainer3/BinarizedImageShader.texture = text
	
	var compute_text = ImageTexture.new()
	compute_text.create_from_image(data)
	$ComputeViewport/BinarizedImageShader.texture = compute_text
	$ComputeViewport.render_target_update_mode = Viewport.UPDATE_ONCE
	
#	var res = binarizeWithColor([data, reference_color_hsv, color_tolerance])
#	$CanvasLayer/VBoxContainer2/VBoxContainer2/BinarizedImage.texture = res

func _on_SpawnIntervalTimer_timeout():
	if spawned_number == object_number:
		$SpawnIntervalTimer.stop()
	else:
		# Spawn an object at the spawn location
		var instance = object.instance()
		
		# Select a random location
		instance.global_transform = $Room/Things/Spawner.get_child(int(rand_range(0, $Room/Things/Spawner.get_child_count()))).global_transform
		
		instance.set_color(colors[int(rand_range(0, colors.size()))])
		
		objects.add_child(instance)
		spawned_number += 1

func _on_ColorPickerButton_color_changed(color):
	reference_color = color
	reference_obj.get_surface_material(0).albedo_color = color
