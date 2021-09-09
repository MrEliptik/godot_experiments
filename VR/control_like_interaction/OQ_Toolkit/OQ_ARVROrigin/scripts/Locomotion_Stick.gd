extends Spatial

export var active = true;
export var debug_information := false;

export var dead_zone = 0.125;

export var move_speed = 1.0;

export var enable_vignette = false;
export var vignette_radius_0 = 0.5;
export var vignette_radius_1 = 0.8;
export var vignette_color = Color(0.0,0.0,0.0,1.0);

onready var movement_vignette_rect = $MovementVignette_ColorRect;

export(vr.AXIS) var move_left_right = vr.AXIS.LEFT_JOYSTICK_X;
export(vr.AXIS) var move_forward_back = vr.AXIS.LEFT_JOYSTICK_Y;

enum MovementOrientation { HEAD, HAND_LEFT, HAND_RIGHT }
export(MovementOrientation) var movement_orientation := MovementOrientation.HEAD

export(vr.LocomotionStickTurnType) var turn_type = vr.LocomotionStickTurnType.CLICK
export var smooth_turn_speed := 90.0;
export var click_turn_angle := 45.0; 
export(vr.AXIS) var turn_left_right = vr.AXIS.RIGHT_JOYSTICK_X;


# this is a basic solution to get some control over movement into the
# application. There can at the moment only be one; It will be overwritten
# when the Feature_PlayerCollision is used; so be careful there.
var move_checker = null;

var is_moving = false;


func _show_debug_information():
	var mcname = "null";
	if (move_checker != null): mcname = move_checker.name;
	vr.show_dbg_info(name, "move_checker=%s" % [mcname]);

func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error("Feature_StickMovement: parent is not ARVROrigin");

	movement_vignette_rect.material.set_shader_param("r0", vignette_radius_0);
	movement_vignette_rect.material.set_shader_param("r1", vignette_radius_1);
	movement_vignette_rect.material.set_shader_param("color", vignette_color);
	
	movement_vignette_rect.visible = false;
	
	var player_collision = get_parent().find_node("Feature_PlayerCollision", false, false);
	if (player_collision != null):
		vr.log_info("Locomotion_Stick: found Feature_PlayerCollision: using it as move_checker");
		move_checker = player_collision;
	
	


func move(dt):
	is_moving = false;
	var dx = vr.get_controller_axis(move_left_right);
	var dy = vr.get_controller_axis(move_forward_back);
	
	if (dx*dx + dy*dy <= dead_zone*dead_zone):
		return;
		
	if (enable_vignette) : movement_vignette_rect.visible = true;
		
	var view_dir: Vector3
	var strafe_dir: Vector3
	
	match movement_orientation:
		MovementOrientation.HEAD:
			view_dir = -vr.vrCamera.global_transform.basis.z;
			strafe_dir = vr.vrCamera.global_transform.basis.x;
		MovementOrientation.HAND_RIGHT:
			view_dir = -vr.rightController.global_transform.basis.z;
			strafe_dir = vr.rightController.global_transform.basis.x;
		MovementOrientation.HAND_LEFT:
			view_dir = -vr.leftController.global_transform.basis.z;
			strafe_dir = vr.leftController.global_transform.basis.x;
	
	view_dir.y = 0.0;
	strafe_dir.y = 0.0;
	view_dir = view_dir.normalized();
	strafe_dir = strafe_dir.normalized();
	
	#var stick_speed 

	#var move = Vector2(dx, dy).normalized() * move_speed;
	var move = Vector2(dx, dy) * move_speed;
	
	var actual_velocity = (view_dir * move.y + strafe_dir * move.x);
	
	if (move_checker):
		actual_velocity = move_checker.oq_locomotion_stick_check_move(actual_velocity, dt);

	vr.vrOrigin.translation += actual_velocity * dt;
	
	is_moving = actual_velocity.length_squared() > 0.0;

var last_click_rotate = false;

var dead_zone_epsilon = 0.8; # multiplyer to have a smaller reset dead zone in click rotate

func turn(dt):
	
	var dlr = -vr.get_controller_axis(turn_left_right);

	if (last_click_rotate): # reset to false only when stick is moved in deadzone; but with epsilon
		last_click_rotate = (abs(dlr) > dead_zone * dead_zone_epsilon); 

	if (abs(dlr) <= dead_zone): 
		return;

	var origHeadPos = vr.vrCamera.global_transform.origin;
	
	# click turning
	if (turn_type == vr.LocomotionStickTurnType.CLICK && !last_click_rotate):
		last_click_rotate = true;
		var dsign = sign(dlr);
		vr.vrOrigin.rotate_y(dsign * deg2rad(click_turn_angle));
			
	# smooth turning
	elif (turn_type == vr.LocomotionStickTurnType.SMOOTH):
		if (enable_vignette) : movement_vignette_rect.visible = true;
		vr.vrOrigin.rotate_y(deg2rad(dlr * smooth_turn_speed * dt));

	# reposition vrOrigin for in place rotation
	vr.vrOrigin.global_transform.origin +=  origHeadPos - vr.vrCamera.global_transform.origin;
	vr.vrOrigin.global_transform = vr.vrOrigin.global_transform.orthonormalized();

# NOTE: we do this in physics_process so after moving the origin
#       the controllers are still rendered in the right position; but we have to keep in mind that this
#       will be tied to the physics framerate then
func _physics_process(dt):
	if (enable_vignette) : movement_vignette_rect.visible = false;
	if (!active): return;
	if (vr.vrOrigin && vr.vrOrigin.is_fixed): 
		return;
	
	turn(dt);
	move(dt);
	
	if (debug_information): _show_debug_information();

