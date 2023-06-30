extends StaticBody2D

@onready var polygon_2d = $Polygon2D
@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var border_polygon = $BorderPolygon

func _ready():
	collision_polygon_2d.polygon = polygon_2d.polygon
	border_polygon.polygon = polygon_2d.polygon
