# This script contains the button logic for the controller
extends ARVRController
class_name OQ_ARVRController

enum TOUCH_CONTROLLER_MODEL_TYPE {
	AUTO,
	QUEST1,
	QUEST2
}

# When set to true it will try to detect and load a model
export var autoload_model = true;

# override for the model used for the touch controller
export (TOUCH_CONTROLLER_MODEL_TYPE) var controller_model_type = TOUCH_CONTROLLER_MODEL_TYPE.AUTO;

# if set to true it will propagate the hand pinch gestures as axis events
export var hand_pinch_to_axis = false;
export var hand_pinch_to_button = true;

var is_hand = false; # this will be updated in the autoload_model

# used for the vr simulation
var _simulation_buttons_pressed       = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

var _buttons_pressed       = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
var _buttons_just_pressed  = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
var _buttons_just_released = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

var _simulation_joystick_axis = [0.0, 0.0, 0.0, 0.0];

export var enable_gesture_to_button = false;

signal signal_controller_type_changed;


# Sets up everything as it is expected by the helper scripts in the vr singleton
func _enter_tree():
	if (!vr):
		vr.log_error(" in OQ_ARVRController._enter_tree(): no vr singleton");
		return;
	if (controller_id == 1):
		if (vr.leftController != null):
			vr.log_warning(" in OQ_ARVRController._enter_tree(): left controller already set; overwriting it");
		vr.leftController = self;
	elif (controller_id == 2):
		if (vr.rightController != null):
			vr.log_warning(" in OQ_ARVRController._enter_tree(): right controller already set; overwriting it");
		vr.rightController = self;
	else:
		vr.log_error(" in OQ_ARVRController._enter_tree(): unexpected controller id %d" % controller_id);

# Reset when we exit the tree
func _exit_tree():
	if (!vr):
		vr.log_error(" in OQ_ARVRController._exit_tree(): no vr singleton");
		return;
	if (controller_id == 1):
		if (vr.leftController != self):
			vr.log_warning(" in OQ_ARVRController._exit_tree(): left controller different");
			return;
		vr.leftController = null;
	elif (controller_id == 2):
		if (vr.rightController != self):
			vr.log_warning(" in OQ_ARVRController._exit_tree(): right controller different");
			return;
		vr.rightController = null;
	else:
		vr.log_error(" in OQ_ARVRController._exit_tree(): unexpected controller id %d" % controller_id);


func get_angular_velocity():
	return vr.get_controller_angular_velocity(controller_id);

func get_angular_acceleration():
	return vr.get_controller_angular_acceleration(controller_id);

func get_linear_velocity():
	if (is_hand && _hand_model):
		return _hand_model.average_velocity;
	return vr.get_controller_linear_velocity(controller_id);

func get_linear_acceleration():
	return vr.get_controller_linear_acceleration(controller_id);


func _ready():
	# check if we already have one of the models attached so autoload still works
	_controller_model = find_node("Feature_*ControllerModel*", false, false);
	_hand_model = find_node("Feature_HandModel*", false, false);

	# heuristic to detect if we want hand behaviour
	if (_hand_model != null): is_hand = true;

# this is a convenience funciton to know the palm orientation; it might be unnecessary
# in the future
func get_palm_transform() -> Transform:
	if (is_hand && _hand_model):
		return _hand_model.palm_marker.global_transform;
	elif (!is_hand && _controller_model):
		return _controller_model.palm_marker.global_transform;

	#fallback if we don't have any information yet
	return global_transform;

# this is another convenience function as sometimes you don't want to flip
# based on the palm orientation
func get_grab_transform() -> Transform:
	if (is_hand && _hand_model):
		return _hand_model.grab_marker.global_transform;
	elif (!is_hand && _controller_model):
		return _controller_model.grab_marker.global_transform;

	#fallback if we don't have any information yet
	return global_transform;

func get_ui_transform() -> Transform:
	if (is_hand && _hand_model):
		return _hand_model.ui_marker.global_transform;
	elif (!is_hand && _controller_model):
		return _controller_model.ui_marker.global_transform;

	#fallback if we don't have any information yet
	return global_transform;


# this is the logic for controller/hand model switching
# at the moment it is not configurable from the outside
var _last_controller_name = null;
var _controller_model : Spatial = null;
var _hand_model : Spatial = null
var _last_controller_model_type = null;

func get_hand_model():
	if (!is_hand):
		vr.log_warning("get_hand_model called on " + name + " but no hand tracking enabled.");
	if (_hand_model == null):
		vr.log_warning("get_hand_model called but no hand model found.");
	return _hand_model;

# loads the corresponding controller model scene
# type: the controller model type to load
# is_left: true if left controller, false if right controller
func _get_touch_controller_model(type,is_left):
	var lOrR = "Left" if is_left else "Right"
	# default to Quest 1 controller
	var model = load(vr.oq_base_dir + "/OQ_ARVRController/Feature_Quest1ControllerModel_%s.tscn" % lOrR).instance()
	
	match type:
		TOUCH_CONTROLLER_MODEL_TYPE.AUTO:
			if vr.is_oculus_quest_1_device():
				vr.log_info("Loading quest 1 controller model")
				model = load(vr.oq_base_dir + "/OQ_ARVRController/Feature_Quest1ControllerModel_%s.tscn" % lOrR).instance()
			elif vr.is_oculus_quest_2_device():
				vr.log_info("Loading quest 1 controller model")
				model = load(vr.oq_base_dir + "/OQ_ARVRController/Feature_Quest2ControllerModel_%s.tscn" % lOrR).instance()
			else:
				vr.log_warning("Unable to automatically determine controller model type.")
		TOUCH_CONTROLLER_MODEL_TYPE.QUEST1:
			model = load(vr.oq_base_dir + "/OQ_ARVRController/Feature_Quest1ControllerModel_%s.tscn" % lOrR).instance()
		TOUCH_CONTROLLER_MODEL_TYPE.QUEST2:
			model = load(vr.oq_base_dir + "/OQ_ARVRController/Feature_Quest2ControllerModel_%s.tscn" % lOrR).instance();
		_:
			vr.log_warning("Unsupported controller model type in _get_touch_controller_model(): " + str(type))
			
	return model

func _auto_update_controller_model():
	var controller_name = get_controller_name();
	
	# determine if we need to make any controller model changes
	var requires_update = false;
	if (_last_controller_name != controller_name):
		requires_update = true;
	if (_last_controller_model_type != controller_model_type):
		requires_update = true;
		
	if (not requires_update):
		return; # do nothing

	_last_controller_name = controller_name;
	_last_controller_model_type = controller_model_type;

	# in vr when we are not connected we hide all controllers (but not in desktop mode)
	if (vr.inVR && controller_name == "Not connected"):
		if (_hand_model != null): _hand_model.visible = false;
		if (_controller_model != null): _controller_model.visible = false;
		emit_signal("signal_controller_type_changed", self);
		return;

	vr.log_info("Switching model for controller '%s' (id %d)" % [controller_name, controller_id]);

	if (controller_name == "Oculus Tracked Left Hand"):
		is_hand = true;
		if (_controller_model != null): _controller_model.visible = false;
		if (autoload_model && _hand_model == null):
			_hand_model = load(vr.oq_base_dir + "/OQ_ARVRController/Feature_HandModel_Left.tscn").instance();
			add_child(_hand_model);
		if (_hand_model != null): _hand_model.visible = true;
	elif (controller_name == "Oculus Tracked Right Hand"):
		is_hand = true;
		if (_controller_model != null): _controller_model.visible = false;
		if (autoload_model && _hand_model == null):
			_hand_model = load(vr.oq_base_dir + "/OQ_ARVRController/Feature_HandModel_Right.tscn").instance();
			add_child(_hand_model);
		if (_hand_model != null): _hand_model.visible = true;

	# default models
	# for now we do not perform more checks and assume that we have touch controllers if
	# there are no hand controllers
	elif (controller_id == 1):
		is_hand = false;
		if (_hand_model != null): _hand_model.visible = false;
		if (autoload_model && _controller_model == null):
			_controller_model = _get_touch_controller_model(controller_model_type,true);
			add_child(_controller_model);
		elif (autoload_model && _controller_model):
			# reload touch controller model based on new type
			remove_child(_controller_model)
			_controller_model = _get_touch_controller_model(controller_model_type,true);
			add_child(_controller_model)
		if (_controller_model != null): _controller_model.visible = true;
	elif (controller_id == 2):
		is_hand = false;
		if (_hand_model != null): _hand_model.visible = false;
		if (autoload_model && _controller_model == null):
			_controller_model = _get_touch_controller_model(controller_model_type,false);
			add_child(_controller_model);
		elif (autoload_model && _controller_model):
			# reload touch controller model based on new type
			remove_child(_controller_model)
			_controller_model = _get_touch_controller_model(controller_model_type,false);
			add_child(_controller_model)
		if (_controller_model != null): _controller_model.visible = true;
	else:
		vr.log_warning("Unknown/Unsupported controller id in _auto_update_controller_model()")

	emit_signal("signal_controller_type_changed", self);



func _button_pressed(button_id):
	return _buttons_pressed[button_id];

func _button_just_pressed(button_id):
	return _buttons_just_pressed[button_id];

func _button_just_released(button_id):
	return _buttons_just_released[button_id];


func _hand_gesture_to_button(i):

	if (i == vr.CONTROLLER_BUTTON.GRIP_TRIGGER):
		var current_gesture = _hand_model.detect_simple_gesture();
		if (current_gesture == "Fist"):
			#vr.show_dbg_info("HandGesture"+str(controller_id), "Fist");
			return 1;
		else:
			#vr.show_dbg_info("HandGesture"+str(controller_id), "");
			pass;

	# keep the hand_pinch to button mapping
	if (hand_pinch_to_button):
		return is_button_pressed(i);


func _sim_is_button_pressed(i):
	if (vr.inVR):
		if (is_hand):
			if (enable_gesture_to_button):
				return _hand_gesture_to_button(i);
			elif (!hand_pinch_to_button):
				return 0;

		return is_button_pressed(i); # is the button pressed
	else: return _simulation_buttons_pressed[i];

func _sim_get_joystick_axis(i):
	if (vr.inVR):
		if (is_hand && !hand_pinch_to_axis): return 0.0;
		return get_joystick_axis(i);
	else: return _simulation_joystick_axis[i];

func _update_buttons_and_sticks():
	for i in range(0, 16):
		var b = _sim_is_button_pressed(i);

		if (b != _buttons_pressed[i]): # the state of the button did change
			_buttons_pressed[i] = b;   # update the main state of our button
			if (b == 1):              # and check if it was just pressed or released
				_buttons_just_pressed[i] = 1;
			else:
				_buttons_just_released[i] = 1;
		else:                         # reset just pressed/released
			_buttons_just_pressed[i] = 0;
			_buttons_just_released[i] = 0;
			
func update_gesture():
	return _hand_model.detect_simple_gesture()
	
func get_orientation():
	# if palm is facing upward, the dot product between
	# palm normal and UP vector should be 0
	var hand_transform = get_palm_transform()
	var dot_product = hand_transform.basis.x.dot(Vector3.UP)
	return dot_product

var _rumble_intensity = 0.0;
var _rumble_duration = -128.0; #-1 means deactivated so applications can also set their own rumble

func simple_rumble(intensity, duration):
	_rumble_intensity = intensity;
	_rumble_duration = duration;
	
func is_simple_rumbling():
	return (_rumble_duration > 0.0);
	
func _update_rumble(dt):
	if (_rumble_duration < - 100): return;
	set_rumble(_rumble_intensity);
	_rumble_duration -= dt;
	if (_rumble_duration <= 0.0):
		_rumble_duration = -128.0;
		set_rumble(0.0);

var first_time = true;

func _physics_process(_dt):

	#vr.show_dbg_info(str(controller_id), str(_buttons_pressed));

	_auto_update_controller_model();

	if (get_is_active() || !vr.inVR): # wait for active controller; or update if we are in simulation mode

		_update_buttons_and_sticks();
		
		_update_rumble(_dt);

		# this avoid getting just_pressed events when a key is pressed and the controller becomes
		# active (like it happens on vr.scene_change!)
		if (first_time):
			_update_buttons_and_sticks();
			first_time = false;
			
		if get_name() != "OQ_LeftController": return
		if $Feature_HandModel_Left.detect_simple_gesture() == "Two":
			$PortableMenu.visible = true
		else:
			$PortableMenu.visible = false
