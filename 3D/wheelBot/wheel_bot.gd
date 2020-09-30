extends KinematicBody

const LEANING_SPEED = 40
const MAX_ANGLE = 25
const MAX_LEANING_ANGLE = 15.0

var gravity = -20
var velocity = Vector3()


const SPEED = 25
const ROT_SPEED = 2.5
const ACCELERATION = 15
const DE_ACCELERATION = 30
const MAX_CAMERA_ROTATION = 90

########################################
# Input
export var joy_steering = JOY_ANALOG_LX
export var joy_camera = JOY_ANALOG_RX 
export var steering_mult = -1.0
export var joy_throttle = JOY_ANALOG_R2
export var throttle_mult = 1.0
export var joy_brake = JOY_ANALOG_L2
export var brake_mult = 1.0

const JOY_DEADZONE = 0.15

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	velocity.y += gravity * delta
	get_input(delta)
	
	if abs(velocity.x) > 0:
		$AnimationPlayer.play("forward")
		if $Cube.rotation_degrees.z > -MAX_ANGLE:
			$Cube.rotation_degrees.z -= delta * LEANING_SPEED
	else:
		$AnimationPlayer.stop()
		if $Cube.rotation_degrees.z <= 0:
			$Cube.rotation_degrees.z += delta * LEANING_SPEED * 2
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	

func get_input(delta):
	# TODO: cleanup the code
	
	# Gamepad
	var in_steer = Input.get_joy_axis(0, joy_steering)
	var steer_val = 0
	if abs(in_steer) > JOY_DEADZONE:
		steer_val = steering_mult * in_steer
	var throttle_val = throttle_mult * Input.get_joy_axis(0, joy_throttle)
	var brake_val = brake_mult * Input.get_joy_axis(0, joy_brake)
	
	var in_move_camera = Input.get_joy_axis(0, joy_camera)
	var move_camera_val = 0
	if abs(in_move_camera) > JOY_DEADZONE:
		move_camera_val = steering_mult * in_move_camera
		# User want to rotate the camera, we must disable the camera target
		# as it will try to fight the rotation
		$CameraOrbit.get_child(0).enabled = false
	else:
		$CameraOrbit.get_child(0).enabled = true
	print(move_camera_val)
	
	$CameraOrbit.rotation_degrees.y += move_camera_val * MAX_CAMERA_ROTATION * delta
	
	var angle = steer_val * MAX_LEANING_ANGLE
	$Rim.rotation_degrees.x = -angle
	$Cube.rotation_degrees.x = -angle
	$Tire.rotation_degrees.x = -angle
	
	# Keyboard
	var vy = velocity.y
	velocity = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity += transform.basis.x * SPEED
	if Input.is_action_pressed("ui_down"):
		velocity += -transform.basis.x * SPEED
	if Input.is_action_pressed("ui_right"):
		rotate_y(-ROT_SPEED * delta)
	if Input.is_action_pressed("ui_left"):
		rotate_y(ROT_SPEED * delta)
		
	velocity += transform.basis.x * throttle_val * SPEED
	rotate_y(steer_val * ROT_SPEED * delta)
		
	velocity.y = vy
