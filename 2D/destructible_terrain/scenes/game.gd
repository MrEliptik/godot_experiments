extends Node2D

onready var line = $Line2D

var max_points = 2000.0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	update_trajectory(delta)
	
func update_trajectory(delta):
	line.clear_points()
	var pos = $Player/RotPoint/ShootPoint.global_position
	var vel = $Player/RotPoint/ShootPoint.global_transform.x * $Player.bullet_velocity
	for i in max_points:
		line.add_point(pos)
		vel.y += $Player.gravity * delta
		pos += vel * delta
		if Geometry.is_point_in_polygon($Terrain/Polygon2D.to_local(pos), $Terrain/Polygon2D.polygon):
			break
