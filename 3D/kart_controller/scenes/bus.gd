extends Spatial

onready var sphere = $Sphere
onready var kart = $"HCR2 Bus"

var speed: float = 150.0
var rot_speed: float = 1.75
var friction: float = 0.85
var turn_threshold: float = 1.0
var cam_speed = 2

var rotation_y = 0

func _ready():
	pass 
	
func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	### CAMERA
	var rot = .0
	rot = -Input.get_action_strength("cam_left") + Input.get_action_strength("cam_right")
	if rot != 0:
		$"HCR2 Bus/CamRotPoint".rotate_y(rot * cam_speed * delta)
	else:
		var curr_rot = $"HCR2 Bus/CamRotPoint".rotation_degrees.y
		# Multiply by sign of curr_rot to avoid full rotation to go to 180° or -180°
		$"HCR2 Bus/CamRotPoint".rotation_degrees.y = lerp(curr_rot, 180*sign(curr_rot), 2*delta)
	
	# Make the kart follow the ball and keep the transform of the kart
	# Update in process otherwise in physics process it will always lag behind
	kart.transform.origin = sphere.transform.origin + Vector3(.0, -0.984, .0)


func _physics_process(delta):
	if !$"HCR2 Bus"/RayCast.is_colliding(): return
	
	var throttle = 0.0
	var brake = 0.0
	var dir = Vector3.ZERO

	throttle = Input.get_action_strength("throttle") - Input.get_action_strength("brake")
	dir = Input.get_action_strength("left") - Input.get_action_strength("right")
	
	$"HCR2 Bus".lean(throttle, dir)

	throttle *= speed
	
	if sphere.linear_velocity.length() > turn_threshold:
		rotation_y = lerp(rotation_y, rotation_y + (dir * rot_speed), delta)
	
	# Rotate the kart based on collision normal to follow the floor inclination
	$"HCR2 Bus/RayCast".force_raycast_update()
	if $"HCR2 Bus/RayCast".is_colliding():
		var normal = $"HCR2 Bus/RayCast".get_collision_normal()
		var kart_transform = $"HCR2 Bus".global_transform
		kart_transform.basis.y = normal.normalized()
		kart_transform.basis.x = -kart_transform.basis.z.cross(normal)
		kart_transform.basis = kart_transform.basis.orthonormalized()
		$"HCR2 Bus".global_transform = $"HCR2 Bus".global_transform.interpolate_with(kart_transform, 10 * delta)
		
	# Apply steering
	kart.rotation.y = rotation_y
	
	if Input.is_action_just_pressed("jump"):
		sphere.apply_central_impulse(Vector3.UP * 30.0)

	# Apply forward force based on kart's orientation
	sphere.add_central_force(kart.global_transform.basis.z * throttle)
	
func set_cam(cam):
	$CamRotPoint/CamPoint/RemoteTransform.remote_path = cam
