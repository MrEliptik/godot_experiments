extends RigidBody

onready var rays = get_tree().get_nodes_in_group("Raycasts")

var speed = 15000
var turn_speed = 2000
var reverse_speed = 10000
var hover_force = 500

func _ready():
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				hover_force += 20
			if event.button_index == BUTTON_WHEEL_DOWN:
				hover_force -= 20
			hover_force = clamp(hover_force, 0, 1200)

func _physics_process(delta):
	# Loop through rays
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var collision_point = ray.get_collision_point()
			
			# Calculate distance between ray position and raycast hit
			var dist = collision_point.distance_to(ray.global_transform.origin)
			
			# Apply force based on distance
			add_force(Vector3.UP * (1/dist) * hover_force * delta, ray.global_transform.origin - global_transform.origin)
			
	# Apply force to move
	if Input.is_action_pressed("forward"):
		add_central_force(-global_transform.basis.x * speed * delta)
	if Input.is_action_pressed("back"):
		add_central_force(global_transform.basis.x * speed * delta)
	
	# Apply torque to rotate
	if Input.is_action_pressed("right"):
		add_torque(-global_transform.basis.y * turn_speed * delta)
	if Input.is_action_pressed("left"):
		add_torque(global_transform.basis.y * turn_speed * delta)
