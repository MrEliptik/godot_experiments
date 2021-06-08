extends Spatial


func _ready():
	pass
	
func _process(delta):
	var accel = Input.get_accelerometer()
	print(accel)
