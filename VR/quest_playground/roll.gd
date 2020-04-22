extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	set_scale(Vector3(0.1, 0.1, 0.1))


func _integrate_forces(state):
	pass
	#set_scale(Vector3(0.1, 0.1, 0.1))

func _on_Timer_timeout():
	pass
	#$Roll.mode = RigidBody.MODE_STATIC
	#$Roll.sleeping = true # way less perf
