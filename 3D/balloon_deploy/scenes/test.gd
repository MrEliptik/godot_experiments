extends Spatial

const balloon = preload("res://scenes/balloon.tscn")

func _ready():
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("add"):
		var instance = balloon.instance()
		add_child(instance)
		instance.global_transform.origin = $Package/SpawnPoint.global_transform.origin
		
		## Add pinjoint
		var pinjoint = PinJoint.new()
		pinjoint.set("nodes/node_a", instance.get_path()) 
		pinjoint.set("nodes/node_b", $Package.get_path())
		add_child(pinjoint)
		pinjoint.global_transform.origin = (instance.global_transform.origin - $Package.global_transform.origin) / 2

	if Input.is_action_just_pressed("remove"):
		var balloons = get_tree().get_nodes_in_group("Balloons")
		if !balloons: return
		balloons[0].queue_free()
		
	var p = Array()
	var ig = $DrawLine
	ig.clear()
	ig.begin(Mesh.PRIMITIVE_LINES)
	for balloon in get_tree().get_nodes_in_group("Balloons"):
		p.append($Package.transform.origin)
		p.append(balloon.transform.origin)
		
		for x in p:
			ig.add_vertex(x)
			
	ig.end()

	$Camera.look_at($Package.global_transform.origin, Vector3.UP)
