extends Spatial

var max_lean_side := 8.0
var max_lean_front := 12.0

func _ready():
	pass
	
func lean(throttle, rot_dir):
#	if throttle != 0:
#		var val = lerp($HCR2_Bus_Body.rotation_degrees.z, max_lean_front * throttle, abs(throttle))
#		$HCR2_Bus_Body.rotation_degrees.x = -val
#	else:
#		$HCR2_Bus_Body.rotation_degrees.x = 0
		
	if rot_dir != 0:
		var val = lerp($HCR2_Bus_Body.rotation_degrees.z, max_lean_side * rot_dir, abs(rot_dir))
		$HCR2_Bus_Body.rotation_degrees.z = val
	else:
		$HCR2_Bus_Body.rotation_degrees.z = 0
		
