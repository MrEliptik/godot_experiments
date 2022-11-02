extends Node

onready var camera2D: Camera2D = $Camera2D
onready var camera3D: Camera = $Camera
onready var tween: Tween = $Tween

var transitioning: bool = false

func _ready() -> void:
	camera2D.current = false
	camera3D.current = false

func switch_camera(from, to) -> void:
	from.current = false
	to.current = true

func transition_camera2D(from: Camera2D, to: Camera2D, duration: float = 1.0) -> void:
	if transitioning: return
	# Copy the parameters of the first camera
	camera2D.zoom = from.zoom
	camera2D.offset = from.offset
	camera2D.light_mask = from.light_mask
	
	# Move our transition camera to the first camera position
	camera2D.global_transform = from.global_transform
	
	# Make our transition camera current
	camera2D.current = true
	
	transitioning = true
	
	# Move to the second camera, while also adjusting the parameters to
	# match the second camera
	tween.remove_all()
	tween.interpolate_property(camera2D, "global_transform", camera2D.global_transform, 
		to.global_transform, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(camera2D, "zoom", camera2D.zoom, 
		to.zoom, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(camera2D, "offset", camera2D.offset, 
		to.offset, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	# Wait for the tween to complete
	yield(tween, "tween_all_completed")
	
	# Make the second camera current
	to.current = true
	transitioning = false

func transition_camera3D(from: Camera, to: Camera, duration: float = 1.0) -> void:
	if transitioning: return
	# Copy the parameters of the first camera
	camera3D.fov = from.fov
	camera3D.cull_mask = from.cull_mask
	
	# Move our transition camera to the first camera position
	camera3D.global_transform = from.global_transform
	
	# Make our transition camera current
	camera3D.current = true
	
	transitioning = true
	
	# Move to the second camera, while also adjusting the parameters to
	# match the second camera
	tween.remove_all()
	tween.interpolate_property(camera3D, "global_transform", camera3D.global_transform, 
		to.global_transform, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(camera3D, "fov", camera3D.fov, 
		to.fov, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	# Wait for the tween to complete
	yield(tween, "tween_all_completed")
	
	# Make the second camera current
	to.current = true
	transitioning = false
