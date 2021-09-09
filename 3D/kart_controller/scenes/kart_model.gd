extends Spatial

var max_lean := 2.0

func _ready():
	pass
	
func lean(dir):
	$Kart.rotation_degrees.z = lerp($Kart.rotation_degrees.z, max_lean * dir, abs(dir))
