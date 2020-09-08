extends Spatial

const Z_FRONT = -1 #in this game the front side is towards negative Z
const THRUST_Z = 2000
const THRUST_TURN = 3200

var wasThrust = false #particles enabled?
onready var plane = $reggiane
# damping: see linear and angular damping parameters

func _physics_process(delta):
	if Input.is_action_pressed("ui_accept"):
		plane.add_central_force(transform.basis.z * Z_FRONT * THRUST_Z)
		if !wasThrust:
			wasThrust = true
	else:
		if wasThrust:
			wasThrust=false
			
	if Input.is_action_pressed("ui_down"): #dive up
		plane.add_torque(global_transform.basis.x * -THRUST_TURN * Z_FRONT)
	if Input.is_action_pressed("ui_up"): #dive down
		plane.add_torque(global_transform.basis.x * THRUST_TURN * Z_FRONT)
	if Input.is_action_pressed("ui_left"):
		plane.add_torque(global_transform.basis.z * -THRUST_TURN * Z_FRONT)
	if Input.is_action_pressed("ui_right"):
		plane.add_torque(global_transform.basis.z * THRUST_TURN * Z_FRONT)
