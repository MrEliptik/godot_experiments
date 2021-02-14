extends RigidBody

onready var points = get_tree().get_nodes_in_group("Points")

var speed = 50
var reverse_speed = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	# Loop through rays and points
	for i in range(points.size()):
		var point = points[i]
		var ray = point.get_child(0)
		ray.rotation = -rotation
		ray.force_raycast_update()
		if ray.is_colliding():
			var collision_point = ray.get_collision_point()
			
			# Calculate distance between point and raycast hit
			var dist = collision_point.distance_to(point.global_transform.origin)
			var force_vec = (point.global_transform.origin - collision_point).normalized()
			
			# Apply force based on distance
			add_force(Vector3.UP * (1/dist) * 10, point.global_transform.origin * delta)
			#add_force(force_vec * (1/dist) * 10, point.global_transform.origin * delta)
			
			var board_pos = get_global_transform().origin
			var thruster_pos = $ThrusterPos.get_global_transform().origin
			# Apply force to move
			if Input.is_action_pressed("forward"):
				#add_force(-global_transform.basis.x * speed * delta, board_pos - thruster_pos)
				add_central_force(-global_transform.basis.x * speed * delta)
				#add_central_force(-transform.basis.x * speed * delta)
				#apply_central_impulse(-global_transform.basis.x * speed * delta)
			if Input.is_action_pressed("back"):
				#add_force(global_transform.basis.x * reverse_speed * delta, board_pos - thruster_pos)
				add_central_force(transform.basis.x * speed * delta)
			
			# Apply torque to rotate
			if Input.is_action_pressed("forward"):
				pass
				#add_torque()
			if Input.is_action_pressed("back"):
				pass
