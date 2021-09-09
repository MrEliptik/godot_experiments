# The Feature_VRSimulator provides some basic functionality to control the ARVRNodes
# via keyboard for desktop debugging and basic tests
extends Spatial

export var active = true;

export var walk_speed = 1.0;


export var controller_move_speed = 0.002;

export var player_height = 1.8;
export var duck_multiply = 0.4;

var _current_player_height = 1.8;

# camera relative positioning of controllers
var left_controller_node = null;
var right_controller_node = null;

var _fly_mode = false;

export var info_label_visible = true;

var info_label = null;
var info_rect = null;

const info_text = """VR Simulator Keys:
 mouse right-click: move (camera or controller)
 W A S D: move (camera or controller)
 space: duck player
 shift:  fly mode (moves origin up)

 hold CTRL/ALT: enable left/right controller for manipulation
   Keypad 8 4 2 6: analog stick
   'Q': index trigger (or left mouse button for right trigger)
   'E': grip trigger 
   Keypad 0: Enter/Menu Button (on left controller)
   Keypad 7: Y/B Button
   Keypad 1: X/A Button
	
 'r': reset controller positions
"""

var initialized = false;

func initialize():
	if (vr.inVR): return;
	if (initialized): return;

	if (!vr.vrOrigin):
		vr.log_error(" in Feature_VRSimulator: no vrOrigin.");
	if (!vr.vrCamera):
		vr.log_error(" in Feature_VRSimulator: no vrCamera.");
	if (!vr.leftController):
		vr.log_error(" in Feature_VRSimulator: no leftController.");
	if (!vr.rightController):
		vr.log_error(" in Feature_VRSimulator: no rightController.");

	# set up everything for simulation
	left_controller_node = Spatial.new();
	vr.vrCamera.add_child(left_controller_node);

	right_controller_node = Spatial.new();
	vr.vrCamera.add_child(right_controller_node);


	# show some keyboard info in a UI overlay
	info_label = Label.new();
	info_label.text = info_text;
	var m = 8;
	info_label.margin_left = m;
	info_label.margin_right = m;
	info_label.margin_top = m;
	info_label.margin_bottom = m;
	info_rect = ColorRect.new();
	
	info_rect.color = Color(0, 0, 0, 0.7);
	info_rect.rect_size = info_label.get_minimum_size(); #Vector2(128, 128);
	info_rect.add_child(info_label);
	add_child(info_rect);

	_current_player_height = player_height;
	vr.vrCamera.translation.y = _current_player_height;
	_reset_controller_position();
	initialized = true;


func _reset_controller_position():
	left_controller_node.translation = Vector3(-0.2, -0.1, -0.4);
	right_controller_node.translation = Vector3( 0.2, -0.1, -0.4);
	_update_virtual_controller_position();

# moves the ARVRController nodes to the simulated position
func _update_virtual_controller_position():
	if (vr.leftController && left_controller_node):
		vr.leftController.global_transform = left_controller_node.global_transform;
	if (vr.rightController && right_controller_node):
		vr.rightController.global_transform = right_controller_node.global_transform;


func _is_interact_left():
	return Input.is_key_pressed(KEY_CONTROL);

func _is_interact_right():
	return Input.is_key_pressed(KEY_ALT);


func _interact_move_controller(dir, rotate):
	if (_is_interact_left()):
		if (left_controller_node): 
			left_controller_node.rotate_x(rotate.x);
			left_controller_node.rotate_y(rotate.y);
			left_controller_node.translation += dir;
	if (_is_interact_right()):
		if (right_controller_node): 
			right_controller_node.rotate_x(rotate.x);
			right_controller_node.rotate_y(rotate.y);
			right_controller_node.translation += dir;
	_update_virtual_controller_position();




func _update_keyboard(dt):
	
	_fly_mode = Input.is_key_pressed(KEY_SHIFT);

	var dir = Vector3(0,0,0);
	if (Input.is_key_pressed(KEY_W)):
		dir += Vector3(0,0,-1);
	if (Input.is_key_pressed(KEY_S)):
		dir += Vector3(0,0,1);
	if (Input.is_key_pressed(KEY_A)):
		dir += Vector3(-1,0,0);
	if (Input.is_key_pressed(KEY_D)):
		dir += Vector3(1,0,0);
	if (Input.is_key_pressed(KEY_V)):
		dir += Vector3(0,-1,0);
	if (Input.is_key_pressed(KEY_F)):
		dir += Vector3(0,1,0);

	if (_is_interact_left() || _is_interact_right()):
		if (dir.length_squared() > 0.01):
			_interact_move_controller(Vector3(0.0, 0.0, dir.z * dt), Vector3(dir.y, dir.x, 0.0) * 8.0 * dt);
	else:
		dir = vr.vrCamera.transform.basis.xform((dir));
		if (_fly_mode): 
			vr.vrOrigin.translation = vr.vrOrigin.translation + dir.normalized() * dt  * walk_speed;
		else:
			dir.y = 0.0;
			if (dir.length_squared() > 0.01):
				vr.vrCamera.translation = vr.vrCamera.translation + dir.normalized() * dt  * walk_speed;
				_update_virtual_controller_position();
			
	# Num pad for controller keys:
	var stick_x = 0.0
	var stick_y = 0.0
	
	if (Input.is_key_pressed(KEY_KP_4) || Input.is_key_pressed(KEY_4)): stick_x = -1.0;
	if (Input.is_key_pressed(KEY_KP_6) || Input.is_key_pressed(KEY_6)): stick_x = 1.0;
	if (Input.is_key_pressed(KEY_KP_8) || Input.is_key_pressed(KEY_8)): stick_y = 1.0;
	if (Input.is_key_pressed(KEY_KP_2) || Input.is_key_pressed(KEY_2)): stick_y = -1.0;
	
	#var button_grip_trigger = 1 if (Input.is_mouse_button_pressed(1)) else 0;
	var button_grip_trigger = 1 if (Input.is_key_pressed(KEY_E)) else 0;
	var button_index_trigger = 1 if (Input.is_key_pressed(KEY_Q)) else 0;
	var button_YB = 1 if (Input.is_key_pressed(KEY_KP_7) || Input.is_key_pressed(KEY_7)) else 0;
	var button_XA = 1 if (Input.is_key_pressed(KEY_KP_1) || Input.is_key_pressed(KEY_1)) else 0;
	
	var button_enter =  1 if (Input.is_key_pressed(KEY_KP_0) || Input.is_key_pressed(KEY_0)) else 0;
	
	# allow button enter always as it is only on left controller
	if (vr.leftController):
		vr.leftController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.ENTER] = button_enter;
	
	if (vr.rightController):
		if (Input.is_mouse_button_pressed(1)):
			vr.rightController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.INDEX_TRIGGER] = 1;
		else:
			vr.rightController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.INDEX_TRIGGER] = 0;
	
	if (_is_interact_left() && vr.leftController):
		vr.leftController._simulation_joystick_axis[vr.CONTROLLER_AXIS.JOYSTICK_X] = stick_x;
		vr.leftController._simulation_joystick_axis[vr.CONTROLLER_AXIS.JOYSTICK_Y] = stick_y;
		
		vr.leftController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.GRIP_TRIGGER] = button_grip_trigger;
		vr.leftController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.INDEX_TRIGGER] = button_index_trigger;
		vr.leftController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.YB] = button_YB;
		vr.leftController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.XA] = button_XA;
		
	if (_is_interact_right() && vr.rightController):
		vr.rightController._simulation_joystick_axis[vr.CONTROLLER_AXIS.JOYSTICK_X] = stick_x;
		vr.rightController._simulation_joystick_axis[vr.CONTROLLER_AXIS.JOYSTICK_Y] = stick_y;

		vr.rightController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.GRIP_TRIGGER] = button_grip_trigger;
		vr.rightController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.INDEX_TRIGGER] = button_index_trigger;
		vr.rightController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.YB] = button_YB;
		vr.rightController._simulation_buttons_pressed[vr.CONTROLLER_BUTTON.XA] = button_XA;




	



func _input(event):
	if vr.inVR || !active: return;
	

	# basic keyboard events
	if (event is InputEventKey && event.pressed):
		if (event.scancode == KEY_R):
			_reset_controller_position();
			
	_current_player_height = player_height;
	if (Input.is_key_pressed(KEY_SPACE)):
		_current_player_height = player_height * duck_multiply;

	vr.vrCamera.translation.y = _current_player_height;


	# camera movement on mouse movement
	if (event is InputEventMouseMotion && Input.is_mouse_button_pressed(2)):
		if (_is_interact_left() || _is_interact_right()):
			var move = Vector3(event.relative.x, -event.relative.y, 0.0);
			_interact_move_controller(move * controller_move_speed, Vector3(0,0,0));
		else:
			var yaw = event.relative.x;
			var pitch = event.relative.y;
			vr.vrCamera.rotate_y(deg2rad(-yaw));
			vr.vrCamera.rotate_object_local(Vector3(1,0,0), deg2rad(-pitch));

	_update_virtual_controller_position();


func _process(dt):
	if vr.inVR || !active: return;
	
	if (!initialized): initialize();

	info_rect.visible = info_label_visible;

	_update_keyboard(dt);



