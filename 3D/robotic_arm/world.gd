extends Spatial

const object = preload("res://object.tscn")

const MAX_FOV = 96
const MIN_FOV = 33

export var object_number = 10000
export var spawn_time_interval = 1.0
export var reference_color = Color("#fc1b04") 
export var color_tolerance = 4.5

const HSV = preload("res://tools/hsv.gd")
onready var objects = $Room/Objects
onready var reference_obj = $Room/Reference/ReferenceObject

# Camera zoom & rotation
var mouse_sens = 0.15
var zoom_sens = 3
var middle_button_clicked = false

# Object colors
var colors = [Color("#0C96BE"), Color("B023DD"), Color("857f10"), Color("#00FE3A")]
var spawned_number = 0

# CV & arm
var blobs = null
var target = null
var target_grabbed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
		
	$Room/robotic_arm/Armature/Skeleton/SkeletonIK.start(true)
	
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
	blobs = detectColorBlob(compute_data, Color(1.0, 1.0, 1.0, 1.0))
	
	if !blobs.empty():
		var point = blobs[0].center()
		target = point
	else:
		target = null
		
	move_arm()
	
	var data = $Room/robotic_arm/Viewport.get_texture().get_data()
	
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

func move_arm():
	if target:
		# We arrived to the target
		if !$Room/robotic_arm/Armature/Skeleton/SkeletonIK.is_running():
			grab()
		# We grabbed tha target, go to drop position
		if target_grabbed:
			$Room/robotic_arm/Target.global_transform.origin = $Room/DropPosition.global_transform.origin
			$Room/robotic_arm/Armature/Skeleton/SkeletonIK.start(true)
			if !$Room/robotic_arm/Armature/Skeleton/SkeletonIK.is_running():
				$Room/robotic_arm/Armature/Skeleton/BoneAttachment2.get_child(1).let_go()
				$Room/robotic_arm/Armature/Skeleton/BoneAttachment2/Area.monitoring = false
				target_grabbed = false
				target = null
		# We go to the target position
		else:
			$Room/robotic_arm/Target.global_transform.origin = $Room/robotic_arm/Viewport/Camera.project_position(target, 1.0)
			$Room/robotic_arm/Armature/Skeleton/SkeletonIK.start(true)
	# No target, we go to rest position
	else:
		$Room/robotic_arm/Target.global_transform.origin = $Room/RestPosition.global_transform.origin
		$Room/robotic_arm/Armature/Skeleton/SkeletonIK.start(true)
		
func grab():
	$Room/robotic_arm/Armature/Skeleton/BoneAttachment2/Area.monitoring = true
	var bodies = $Room/robotic_arm/Armature/Skeleton/BoneAttachment2/Area.get_overlapping_bodies()
	if bodies.empty(): return
	for body in bodies:
		if body.has_method("pick_up"):
			body.pick_up($Room/robotic_arm/Armature/Skeleton/BoneAttachment2)
			target_grabbed = true
			$Room/robotic_arm/Armature/Skeleton/BoneAttachment2/Area.monitoring = false
	
func binarizeWithColor(args):
	var im = args[0]
	var color = args[1]
	var tolerance = args[2]
	
	var binarized_im = Image.new()
	binarized_im.copy_from(im)
	
	# Lock images before reading and setting
	im.lock()
	binarized_im.lock()
	
	for i in range(im.get_width()):
		for j in range(im.get_height()):
			var pixel = im.get_pixel(i,j)
			var pixel_hsv = HSV.RGB_to_HSV(pixel)
			var dist = pixel_hsv.distance_to(color)
			#print(dist)
			if dist < tolerance:
				binarized_im.set_pixel(i, j, Color(1.0,1.0,1.0))
			else:
				binarized_im.set_pixel(i, j, Color(0.0,0.0,0.0))
				
	im.unlock()
	binarized_im.unlock()
	var binarized_texture = ImageTexture.new()
	binarized_texture.create_from_image(binarized_im)
	
	return binarized_texture
	
func detectColorBlob(im, color):	
	if !im: return
	
	# Lock image before reading
	im.lock()
	var binarized_im = Image.new()
	binarized_im.copy_from(im)
	im.unlock()

	var blobs = []
	
	var h = binarized_im.get_height()
	var w = binarized_im.get_width()

	binarized_im.lock()
	
	for i in range(h):
		for j in range(w):
			# Not white pixel, we don't care
			var pixel = binarized_im.get_pixel(i, j)
			#print(pixel)
			if pixel == color:	
				var found = false
				# Loop through existing blobs
				for blob in blobs:
					if blob.is_near(i, j):
						blob.add(i, j)
						found = true
						break
				if !found:
					var b = Blob.new()
					b.blob(i, j)
					blobs.append(b)
#
	# Unlock when finished
	binarized_im.unlock()
#
	return blobs

class Blob:
	var min_x : float
	var min_y : float
	var max_x : float
	var max_y : float
	
	func blob(x, y):
		min_x = x
		min_y = y
		max_x = x
		max_y = y
		
	func rect():
		return Rect2(min_x, min_y, max_x-min_x, max_y-min_y)
		
	func center():
		return Vector2(rect().position.x + (rect().size.x/2), rect().position.y + (rect().size.y/2))
		
	func add(x, y):
		min_x = min(min_x, x)
		min_y = min(min_y, y)
		max_x = max(min_x, x)
		max_y = max(min_y, y)
		
	func is_near(x, y):
		var cx = (min_x+max_x) / 2
		var cy = (min_y+max_y) / 2
		
		var d = Vector2(cx, cy).distance_to(Vector2(x, y))
		if d < 25: return true
		else: return false

func _on_SpawnIntervalTimer_timeout():
	if spawned_number == object_number:
		$SpawnIntervalTimer.stop()
	else:
		# Spawn an object at the spawn location
		var instance = object.instance()
		
		# Select a random location
		instance.global_transform = $Room/Spawner.get_child(int(rand_range(0, $Room/Spawner.get_child_count()))).global_transform
		
		# TODO: Choose a color
		instance.set_color(colors[int(rand_range(0, colors.size()))])
		
		objects.add_child(instance)
		spawned_number += 1

func _on_ColorPickerButton_color_changed(color):
	reference_color = color
	reference_obj.get_surface_material(0).albedo_color = color
