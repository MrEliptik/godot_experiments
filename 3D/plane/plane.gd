extends Spatial


### CAR
#########################################
# Behavior values
export var MAX_ENGINE_FORCE = 200.0
export var MAX_BRAKE_FROCE = 5.0
export var MAX_STEER_ANGLE = 0.5

export var steer_speed = 5.0

var steer_target = 0.0
var steer_angle = 0.0

### PLANE
########################################
#const Z_FRONT = -1 #in this game the front side is towards negative Z
#const THRUST_Z = 2000
#const THRUST_TURN = 3200

#var wasThrust = false #particles enabled?
onready var plane = $reggiane
## damping: see linear and angular damping parameters

########################################
# Input
export var joy_steering = JOY_ANALOG_LX
export var steering_mult = -1.0
export var joy_throttle = JOY_ANALOG_R2
export var throttle_mult = 1.0
export var joy_brake = JOY_ANALOG_L2
export var brake_mult = 1.0

const JOY_DEADZONE = 0.15


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var in_steer = Input.get_joy_axis(0, joy_steering)
	var steer_val = 0
	if abs(in_steer) > JOY_DEADZONE:
		steer_val = steering_mult * in_steer
	var throttle_val = throttle_mult * Input.get_joy_axis(0, joy_throttle)
	var brake_val = brake_mult * Input.get_joy_axis(0, joy_brake)
	
	if Input.is_action_pressed("ui_up"):
		throttle_val = 1.0
	if Input.is_action_pressed("ui_down"):
		brake_val = 1.0
	if Input.is_action_pressed("ui_left"):
		steer_val = 1.0
	elif Input.is_action_pressed("ui_right"):
		steer_val = -1.0
		
	plane.engine_force = throttle_val * MAX_ENGINE_FORCE
	plane.brake = brake_val * MAX_BRAKE_FROCE
	
	steer_target = steer_val * MAX_STEER_ANGLE
	if(steer_target < steer_angle):
		steer_angle -= steer_speed * delta
		if (steer_target > steer_angle):
			steer_target = steer_angle
	elif(steer_target > steer_angle):
		steer_angle += steer_speed * delta
		if (steer_target < steer_angle):
			steer_target = steer_angle
			
	plane.steering = steer_angle

##### AIRPLANE CODE
#
#func _physics_process(delta):
#	if Input.is_action_pressed("ui_accept"):
#		plane.add_central_force(transform.basis.z * Z_FRONT * THRUST_Z)
#		if !wasThrust:
#			wasThrust = true
#	else:
#		if wasThrust:
#			wasThrust=false
#
#	if Input.is_action_pressed("ui_down"): #dive up
#		plane.add_torque(global_transform.basis.x * -THRUST_TURN * Z_FRONT)
#	if Input.is_action_pressed("ui_up"): #dive down
#		plane.add_torque(global_transform.basis.x * THRUST_TURN * Z_FRONT)
#	if Input.is_action_pressed("ui_left"):
#		plane.add_torque(global_transform.basis.z * -THRUST_TURN * Z_FRONT)
#	if Input.is_action_pressed("ui_right"):
#		plane.add_torque(global_transform.basis.z * THRUST_TURN * Z_FRONT)
