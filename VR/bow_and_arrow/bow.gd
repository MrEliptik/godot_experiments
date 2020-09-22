extends Spatial

signal body_entered(body)
signal body_exited(body)

signal hand_entered(area)
signal hand_exited(area)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if $RayCast.is_colliding():
		$LaserPoint.global_transform.origin = $RayCast.get_collision_point()
		$LaserPoint.visible = true
		var dist = $RayCast.get_collision_point().distance_to($DistancePoint.global_transform.origin)
		set_distance(dist)
	else:
		$LaserPoint.visible = false
		
func set_distance(dist):
	$DistanceViewport/Distance.text = str(stepify(dist, 0.01)) + " M"
	# Trigger viewport update
	$DistanceViewport.render_target_update_mode = Viewport.UPDATE_ONCE

func _on_ArrowPlacingArea_body_entered(body):
	emit_signal("body_entered", body)

func _on_ArrowPlacingArea_body_exited(body):
	emit_signal("body_exited", body)

func _on_RopeArea_area_entered(area):
	emit_signal("hand_entered", area)

func _on_RopeArea_area_exited(area):
	emit_signal("hand_exited", area)
