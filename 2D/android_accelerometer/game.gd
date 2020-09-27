extends Node2D

const ball = preload("res://ball.tscn")

onready var balls_container = $Balls

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	var accel = Input.get_accelerometer()
	if accel:
		print(accel)

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
