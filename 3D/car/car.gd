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


func _ready():
	pass

func _physics_process(delta):
	var throttle_force = 0.0
	var brake_force = 0.0
	var steer_force = 0.0
	
	throttle_force = Input.get_action_strength("gas")
	engine_force = lerp(engine_force, throttle_force*horse_power, accel_speed*delta)
	
	steer_force = Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
	steering = lerp_angle(steering, steer_force*steer_angle, steer_speed*delta)
	
	brake_force = Input.get_action_strength("brake")
	brake = lerp(brake, brake_force*brake_power, brake_speed*delta)






