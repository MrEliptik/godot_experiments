extends Node2D

const ball = preload("res://ball.tscn")

onready var balls_container = $Balls

const EARTH_GRAVITY = 9.8

# Called when the node enters the scene tree for the first time.
func _ready():
	var gravity_strength = Physics2DServer.area_get_param(get_viewport().find_world_2d().get_space(), Physics2DServer.AREA_PARAM_GRAVITY)
	print(gravity_strength)
	
func _process(delta):
	var accel = Input.get_accelerometer()
	if accel:
		#print(accel)
		var gravity_vector = Vector2(accel.x/EARTH_GRAVITY, -accel.y/EARTH_GRAVITY)
		Physics2DServer.area_set_param(get_viewport().find_world_2d().get_space(), Physics2DServer.AREA_PARAM_GRAVITY_VECTOR, gravity_vector)

func _unhandled_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		var instance = ball.instance()
		instance.global_position = event.position
		balls_container.add_child(instance)
	# On button press
	elif event is InputEventMouseButton and event.is_pressed():
		var instance = ball.instance()
		instance.global_position = get_global_mouse_position()
		balls_container.add_child(instance)
