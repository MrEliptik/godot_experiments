extends Node2D

onready var lightning = $Lightning
var segment_length = 50

func _ready():
	randomize()
	create_lightning() 
	
func create_lightning():
	var points = PoolVector2Array()
	points.append(Vector2(1920.0/2.0, 0.0))
	var curr_point = points[0] * segment_length
	curr_point = curr_point.rotated(deg2rad(rand_range(-80.0, 80.0)))
	print(curr_point)
	points.append(curr_point)
	lightning.points = points
