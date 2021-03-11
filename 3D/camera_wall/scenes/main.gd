extends Spatial

onready var camera = $CamRotPoint/Camera
onready var raycast = $CamRotPoint/Camera/RayCast
onready var player = $Player

const camera_speed = 2

func _ready():
	pass 

func _process(delta):
	# Camera movement
	if Input.is_action_pressed("left"):
		$CamRotPoint.rotation.y -= delta * camera_speed
	elif Input.is_action_pressed("right"):
		$CamRotPoint.rotation.y += delta * camera_speed
	elif Input.is_action_pressed("up"):
		$CamRotPoint.rotation.z += delta * camera_speed
	elif Input.is_action_pressed("down"):
		$CamRotPoint.rotation.z -= delta * camera_speed

func _physics_process(_delta):
	
	# Cast raycast to player
	# Convert to local coords as cast_to is relative to raycast position
	raycast.cast_to = raycast.to_local(player.global_transform.origin)
	
	# Force update to have collision result for this frame, and not the previous
	raycast.force_raycast_update()
	if !raycast.is_colliding(): return
	
	# Get the collider
	var collider = raycast.get_collider()
	if !collider.is_in_group("Walls"): return
	
	# Hide the wall
	collider.set_visible(false)
