extends Node2D

onready var path = $Path2D
onready var l = $Line2D

func _ready():
	for point in path.curve.get_baked_points():  
		l.add_point(point + path.position)
