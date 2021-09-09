extends PinJoint

var a = null
var b = null

func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	global_transform.origin = a.global_transform.origin

func attach(who_a, who_b, where: Vector3):
	a = who_a
	b = who_b
	set("nodes/node_a", who_a.get_path())
	set("nodes/node_b", who_b.get_path())

	global_transform.origin = where
	
	$Line3D.end_point_node = b.get_path()
