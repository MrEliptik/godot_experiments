extends Particles2D

var slow_factor = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func slow_down(val: bool, factor: float):
	slow_factor = factor
	speed_scale = factor
