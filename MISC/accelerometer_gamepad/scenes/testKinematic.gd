extends Node2D


func _ready():
	pass
	
func _process(delta):
	var accel = Input.get_accelerometer()
	$CanvasLayer/HUD.set_values(accel.x, accel.y, accel.z)
