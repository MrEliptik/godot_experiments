extends RigidBody2D

@export var radius: float = 20.0

func _ready():
	radius *= randf_range(0.5, 1.75)
	draw_circle_polygon(32, radius)
	$CollisionShape2D.shape.radius = radius
	
func draw_circle_polygon(points_nb: int, radius: float) -> void:
	var points = PackedVector2Array()
	for i in range(points_nb+1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * radius)
	
	$Polygon2D.polygon = points
