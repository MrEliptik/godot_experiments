extends Spatial

const object = preload("res://object.tscn")

export var object_number = 10000
export var spawn_time_interval = 1.0
export var reference_color = Color("#fc1b04") 
export var color_tolerance = 4.5
export var thread_number = 12

onready var objects = $Room/Objects
onready var reference_obj = $Room/ReferenceObject

var colors = [Color("#0C96BE"), Color("B023DD"), Color("857f10"), Color("#00FE3A")]

var spawned_number = 0
onready var reference_color_hsv = RGBtoHSV(reference_color)

var threads = []
var input_q = Array()
var output_q = Array()
var input_mutex = Mutex.new()
var output_mutex = Mutex.new()

var blobs = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	$Room/robotic_arm/Armature/Skeleton/SkeletonIK.start()
	
	reference_obj.get_surface_material(0).albedo_color = reference_color
	$CanvasLayer/VBoxContainer/ColorPickerButton.color = reference_color
	
	colors.append(reference_color)
	
	# Create X threads
#	for i in range(thread_number):
#		threads.append(Thread.new())
	
	# Start the threads
#	for i in range(thread_number):
#		threads[i].start(self, "threadedbinarizeWithColor", 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CanvasLayer/FPS.text = "FPS: "+ str(Engine.get_frames_per_second())
	
	var data = $Room/robotic_arm/Viewport.get_texture().get_data()
	
	# Test with shader
	var text = ImageTexture.new()
	text.create_from_image(data)
	$CanvasLayer/VBoxContainer2/VBoxContainer3/BinarizedImageShader.texture = text
	
	var compute_text = ImageTexture.new()
	compute_text.create_from_image(data)
	$ComputeViewport/BinarizedImageShader.texture = compute_text
	$ComputeViewport.render_target_update_mode = Viewport.UPDATE_ONCE
	
	# Get previous frame result
	blobs = detectColorBlob($ComputeViewport.get_texture().get_data(), Color(1.0, 1.0, 1.0, 1.0))
	
	if blobs.empty():
		$Room/robotic_arm/Target.global_transform.origin = $Room/robotic_arm/RestPosition.global_transform.origin
	else:
		for blob in blobs:
			var point = blob.center()
			
			$Room/robotic_arm/Target.global_transform.origin = $Room/robotic_arm/Viewport/Camera.project_position(point, 1.0)
		
	
	#$ThreadPool.submit_task(self, "binarizeWithColor", [data, reference_color_hsv, color_tolerance])
	#$FutureThreadPool.submit_task(self, "binarizeWithColor", [data, reference_color_hsv, color_tolerance])

	
	#input_q.append([data, reference_color_hsv, color_tolerance])
	
#	var res = output_q.pop_front()
#	if res != null:
#		$CanvasLayer/VBoxContainer2/VBoxContainer2/BinarizedImage.texture = res
	
#	var res = binarizeWithColor([data, reference_color_hsv, color_tolerance])
#	$CanvasLayer/VBoxContainer2/VBoxContainer2/BinarizedImage.texture = res
	
# Threaded function must have an argument, even if not used
func threadedinarizeWithColor(_userdata):
	while true:
		input_mutex.lock()
		var data = input_q.pop_front()
		input_mutex.unlock()
	
		if data != null:
			output_mutex.lock()
			output_q.append(binarizeWithColor(data))
			output_mutex.unlock()
	
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
			var pixel_hsv : HSV = RGBtoHSV(pixel)
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
	
			
func RGBtoHSV(color_rgb: Color) -> HSV:
	var hsv = HSV.new()
	var _min
	var _max
	var _delta
	
	_min = color_rgb.r if color_rgb.r < color_rgb.g else color_rgb.g 
	_min = _min if _min < color_rgb.b else color_rgb.b
	
	_max = color_rgb.r if color_rgb.r > color_rgb.g else color_rgb.g 
	_max = _max if _max > color_rgb.b else color_rgb.b
	
	hsv.v = _max
	_delta = _max - _min
	if (_delta < 0.00001):
		hsv.s = 0
		hsv.h = 0
		return hsv
	if _max > 0.0:
		hsv.s = _delta / _max
	else:
		hsv.s = 0.0
		hsv.h = NAN
		return hsv
	if color_rgb.r >= _max:
		hsv.h = (color_rgb.g - color_rgb.b) / _delta
	elif color_rgb.g >= _max:
		hsv.h = 2.0 + (color_rgb.b - color_rgb.r) / _delta
	else:
		hsv.h = 4.0 + (color_rgb.r - color_rgb.g) / _delta
		
	hsv.h *= 60.0
	
	if hsv.h < 0.0:
		hsv.h += 360.0
	
	return hsv

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
	reference_color_hsv = RGBtoHSV(color)
	reference_obj.get_surface_material(0).albedo_color = color

func _on_ThreadPool_task_finished(task_tag):
	pass
	
# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	pass
	#thread.wait_to_finish()
	
class HSV:
	var h: float
	var s: float
	var v: float
	
	func distance_to(hsv_color: HSV):
		return Vector3(h, s, v).distance_to(Vector3(hsv_color.h, hsv_color.s, hsv_color.v))


func _on_FutureThreadPool_task_completed(task):
	var _task = task
	print(_task.result)
	$CanvasLayer/VBoxContainer2/VBoxContainer2/BinarizedImage.texture = _task.result
