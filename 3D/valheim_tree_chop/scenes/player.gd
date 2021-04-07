extends KinematicBody

onready var camera = $Pivot/Camera

var gravity: float = -30
var max_speed: float = 8
var mouse_sensitivity: float  = 0.0015  # radians/pixel

var throw_force: float = 200

var velocity: Vector3 = Vector3()

# OBJECT
var collider = null
var previous_collider = null
var picked_up = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func get_input():
	var input_dir = Vector3()
	# desired move in camera direction

	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += camera.global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -camera.global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)
		
func _process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("chop"):
		$Pivot/Axe.chop()
		
func _physics_process(delta):
	
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)


