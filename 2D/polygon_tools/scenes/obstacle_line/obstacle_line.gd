extends StaticBody2D

@onready var polygon_2d = $Polygon2D
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var border_line = $BorderLine

func _ready():
	polygon_2d.polygon = border_line.points
	collision_polygon_2d.polygon = border_line.points
