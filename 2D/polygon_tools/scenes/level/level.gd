extends StaticBody2D

@onready var path_2d = $Path2D
@onready var polygon_2d = $Polygon2D
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var border_line = $BorderLine

func _ready():
	
	var points = path_2d.curve.get_baked_points()
	
	collision_polygon_2d.polygon = points
	border_line.points = points
	polygon_2d.polygon = points
