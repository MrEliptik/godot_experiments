extends Node2D

func _ready() -> void:
	$Destructible/CollisionPolygon2D.polygon = $Polygon2D.polygon
	
func clip(poly):
	var offset_poly = Polygon2D.new()
	offset_poly.global_position = Vector2.ZERO
	## offset the polygon points to take into account the transformation
	var new_values = []
	for point in poly.polygon:
		new_values.append(point+poly.global_position)
	offset_poly.polygon = PoolVector2Array(new_values)
#	get_parent().add_child(offset_poly)
	var res = Geometry.clip_polygons_2d($Polygon2D.polygon, offset_poly.polygon)

	$Polygon2D.polygon = res[0]
	$Destructible/CollisionPolygon2D.set_deferred("polygon", res[0])
