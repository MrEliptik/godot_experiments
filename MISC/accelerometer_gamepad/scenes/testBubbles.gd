extends Node2D

const MAX_Y: float = 288.0
const MAX_X: float = 288.0
const GRAVITY: float = 9.8

func _ready():
	pass
	
func _process(delta):
	var accel = Input.get_accelerometer()
	
	$CanvasLayer/HUD.set_values(accel.x, accel.y, accel.z)
	
	$circle_bubble_outer/circle_bubble_inner.position.y = -accel.y / GRAVITY * MAX_Y
	$circle_bubble_outer/circle_bubble_inner.position.x = accel.x / GRAVITY * MAX_X
