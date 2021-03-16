extends VehicleBody

#########################################
# VEHICLE
var horse_power = 550
var accel_speed = 120
var steer_angle = deg2rad(30)
var steer_speed = 3
var brake_power = 30
var brake_speed = 25


########################################
# GAMEPAD INPUT
export var joy_steer_x = JOY_ANALOG_LX
export var joy_steer_y = JOY_ANALOG_LY
export var joy_throttle = JOY_ANALOG_R2
export var joy_brake = JOY_ANALOG_L2
export var joy_camera_x = JOY_ANALOG_RX
export var joy_camera_y = JOY_ANALOG_RY

const JOY_DEADZONE = 0.15

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var throttle_force = 0.0
	var brake_force = 0.0
	var steer_force = 0.0
	
#	if Input.is_action_pressed("ui_up"):
#		throttle_val = 1.0
#	if Input.is_action_pressed("ui_down"):
#		brake_val = 1.0
#	if Input.is_action_pressed("ui_left"):
#		steer_val = 1.0
#	elif Input.is_action_pressed("ui_right"):
#		steer_val = -1.0
		
	var throttle_input = Input.get_joy_axis(0, joy_throttle)
	if throttle_input > JOY_DEADZONE:
		throttle_force = throttle_input
	
	engine_force = lerp(engine_force, throttle_force*horse_power, accel_speed*delta)
	
	var steer_input = Input.get_joy_axis(0, joy_steer_x)
	if abs(steer_input) > JOY_DEADZONE:
		steer_force = -steer_input
	steering = lerp_angle(steering, steer_force*steer_angle, steer_speed*delta)
	
	var brake_input = Input.get_joy_axis(0, joy_brake)
	if brake_input > JOY_DEADZONE:
		brake_force = brake_input
	brake = lerp(brake, brake_force*brake_power, brake_speed*delta)
	
	## CAMERA
#	var camera_x_input = 0.0
#	camera_x_input = Input.get_joy_axis(0, joy_camera_x)
#	if abs(camera_x_input) > JOY_DEADZONE:
#		$SpringArm.rotation.y += camera_x_input * camera_speed * delta





