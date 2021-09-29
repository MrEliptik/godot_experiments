extends RigidBody2D

func _ready() -> void:
	$CollisionPolygon2D.polygon = $Polygon2D.polygon
