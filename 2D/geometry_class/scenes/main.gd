extends Node2D

func _ready() -> void:
	randomize()
	
	calculate_intersection()
	calculate_union()
	calculate_difference()
	calculate_xor()
	calculate_other()
	inflate_polygon(0.0)
	
func _process(delta: float) -> void:
	calculate_is_inside()
	calculate_closest_points()
	calculate_intersections()

func calculate_intersection():
	print("")
	print("### INTERSECTION ###")
	var res = Geometry.intersect_polygons_2d($Intersection/ShapeA.polygon, $Intersection/ShapeB.polygon)
	print(res)
	## If true, the polygon represents a hole
	print(Geometry.is_polygon_clockwise(res[0]))
	$Intersection/ResultPos/Result.polygon = res[0]
	
	res = Geometry.intersect_polygons_2d($Intersection/ShapeA2.polygon, $Intersection/ShapeB2.polygon)
	print(res)
	## If true, the polygon represents a hole
	print(Geometry.is_polygon_clockwise(res[0]))
	$Intersection/Result2Pos/Result.polygon = res[0]
	
func calculate_union():
	print("")
	print("### UNION ###")
	var res = Geometry.merge_polygons_2d($Union/ShapeA.polygon, $Union/ShapeB.polygon)
	print(res)
	## If true, the polygon represents a hole
	print(Geometry.is_polygon_clockwise(res[0]))
	$Union/ResultPos/Result.polygon = res[0]
	
	res = Geometry.merge_polygons_2d($Union/ShapeA2.polygon, $Union/ShapeB2.polygon)
	print(res)
	## If true, the polygon represents a hole
	print(Geometry.is_polygon_clockwise(res[0]))
	print(Geometry.is_polygon_clockwise(res[1]))
	$Union/Result2Pos/Result.polygon = res[0]
	$Union/Result2Pos/Result2.polygon = res[1]
	
func calculate_difference():
	print("")
	print("### DIFFERENCE ###")
	var res = Geometry.clip_polygons_2d($Difference/ShapeA.polygon, $Difference/ShapeB.polygon)
	print(res)
	## If true, the polygon represents a hole
	print(Geometry.is_polygon_clockwise(res[0]))
	$Difference/ResultPos/Result.polygon = res[0]
	
	res = Geometry.clip_polygons_2d($Difference/ShapeA2.polygon, $Difference/ShapeB2.polygon)
	print(res)
	## If true, the polygon represents a hole
	print(Geometry.is_polygon_clockwise(res[0]))
	print(Geometry.is_polygon_clockwise(res[1]))
	$Difference/Result2Pos/Result.polygon = res[0]
	$Difference/Result2Pos/Result2.polygon = res[1]
	
func calculate_xor():
	print("")
	print("### XOR ###")
	var res = Geometry.exclude_polygons_2d($XOR/ShapeA.polygon, $XOR/ShapeB.polygon)
	print(res)
	## If true, the polygon represents a hole
	print(Geometry.is_polygon_clockwise(res[0]))
	$XOR/ResultPos/Result.polygon = res[0]
	
	res = Geometry.exclude_polygons_2d($XOR/ShapeA2.polygon, $XOR/ShapeB2.polygon)
	print(res)
	## If true, the polygon represents a hole
	print(Geometry.is_polygon_clockwise(res[0]))
	print(Geometry.is_polygon_clockwise(res[1]))
	$XOR/Result2Pos/Result.polygon = res[0]
	$XOR/Result2Pos/Result2.polygon = res[1]

func calculate_is_inside():
	var res = Geometry.is_point_in_polygon($IsInside/ShapeA.to_local($IsInside/Point.global_position), 
		$IsInside/ShapeA.polygon)
	$CanvasLayer/GridContainer/IsInside/Label/Result.text = str(res)
	
	res = Geometry.is_point_in_circle($IsInside/Point2.global_position, 
		$IsInside/ShapeCircle.global_position, 40.0)
	$CanvasLayer/GridContainer/IsInside/Label/Result2.text = str(res)
	
	res = Geometry.point_is_inside_triangle($IsInside/ShapeTriangle.to_local($IsInside/Point3.global_position),
		$IsInside/ShapeTriangle.polygon[0], $IsInside/ShapeTriangle.polygon[1], $IsInside/ShapeTriangle.polygon[2])
	$CanvasLayer/GridContainer/IsInside/Label/Result3.text = str(res)
	
func calculate_closest_points():
	var res = Geometry.get_closest_point_to_segment_2d($ClosestPoint/Point.position, 
		$ClosestPoint/Line2D.points[0], $ClosestPoint/Line2D.points[1])
	
	$ClosestPoint/ResultPoint.position = res
	
	res = Geometry.get_closest_points_between_segments_2d(
		$ClosestPoint/Line2D2.to_global($ClosestPoint/Line2D2.points[0]), 
		$ClosestPoint/Line2D2.to_global($ClosestPoint/Line2D2.points[1]), 
		$ClosestPoint/Line2D3.to_global($ClosestPoint/Line2D3.points[0]), 
		$ClosestPoint/Line2D3.to_global($ClosestPoint/Line2D3.points[1]))
	
#	print(res)
	$ClosestPoint/ResultPoint2.global_position = res[0]
	$ClosestPoint/ResultPoint3.global_position = res[1]
	
func calculate_intersections():
	var res = Geometry.segment_intersects_segment_2d(
		$Intersections/Line2D.to_global($Intersections/Line2D.points[0]), 
		$Intersections/Line2D.to_global($Intersections/Line2D.points[1]),
		$Intersections/Line2D2.to_global($Intersections/Line2D2.points[0]), 
		$Intersections/Line2D2.to_global($Intersections/Line2D2.points[1]))

	if !res: 
		$Intersections/ResultPoint.visible = false
	else:
		$Intersections/ResultPoint.visible = true
		$Intersections/ResultPoint.global_position = res
		
	res = Geometry.segment_intersects_circle(
		$Intersections/Line2D3.to_global($Intersections/Line2D3.points[0]), 
		$Intersections/Line2D3.to_global($Intersections/Line2D3.points[1]),
		$Intersections/ShapeCircle.global_position, 40.0)
	
	if res == -1: 
		$Intersections/ResultPoint2.visible = false
	else:
		$Intersections/ResultPoint2.visible = true
		$Intersections/ResultPoint2.global_position = lerp(
			$Intersections/Line2D3.to_global($Intersections/Line2D3.points[0]), 
			$Intersections/Line2D3.to_global($Intersections/Line2D3.points[1]), 
			res)
			
func calculate_other():
	var res_delaunay = Geometry.triangulate_delaunay_2d($Other/Shape.polygon)
	var res = Geometry.triangulate_polygon($Other/Shape.polygon)
	for i in range(0, res.size(), 3):
		var poly: Polygon2D = Polygon2D.new()
		poly.color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))

		# Result are indexes from the original polygon points
		var vec_array = PoolVector2Array([$Other/Shape.polygon[res[i]], $Other/Shape.polygon[res[i+1]], $Other/Shape.polygon[res[i+2]]])
		poly.polygon = vec_array
		$Other/Result.add_child(poly)
		
func inflate_polygon(value):
#	var res = Geometry.offset_polygon_2d($Other/Shape2.polygon, value)
#	var res = Geometry.offset_polygon_2d($Other/Shape2.polygon, value, Geometry.JOIN_ROUND)
	var res = Geometry.offset_polygon_2d($Other/Shape2.polygon, value, Geometry.JOIN_MITER)
	$Other/Result2/Polygon2D.polygon = PoolVector2Array(res[0])

func _on_HSlider_value_changed(value: float) -> void:
	inflate_polygon(value)
	
