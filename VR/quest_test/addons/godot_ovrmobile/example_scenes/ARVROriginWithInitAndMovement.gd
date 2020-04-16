# ARVROriginWithInitAndMove.[tscn/gd]
#
# This is an example implementaiton on how to initialize the Oculus Mobile Plugin (godot_ovrmobile)
# It can be used as a drop-in solution for quick testing or modified to your needs
# It shows some of the common things needed to interact with the Godot Oculus Mobile Plugin
#
# To view log/print messages use `adb logcat -s godot:* GodotOVRMobile:*` from a command prompt
extends ARVROrigin


# these will be initialized in the _ready() function; but they will be only available
# on device
# the init config is needed for setting parameters that are needed before the VR system starts up
var ovr_init_config = null;


# the other APIs are available during runtime; details about the exposed functions can be found
# in the *.h files in https://github.com/GodotVR/godot_oculus_mobile/tree/master/src/config
var ovr_performance = null;
var ovr_display_refresh_rate = null;
var ovr_guardian_system = null;
var ovr_tracking_transform = null;
var ovr_utilities = null;
var ovr_vr_api_proxy = null;


# some of the Oculus VrAPI constants are defined in this file. Have a look into it to learn more
var ovrVrApiTypes = load("res://addons/godot_ovrmobile/OvrVrApiTypes.gd").new();


func _ready():
	_initialize_ovr_mobile_arvr_interface();


func _process(delta_t):
	_check_and_perform_runtime_config()
	_check_move(delta_t)


# this code check for the OVRMobile inteface; and if successful also initializes the
# .gdns APIs used to communicate with the VR device
func _initialize_ovr_mobile_arvr_interface():
	# Find the OVRMobile interface and initialise it if available
	var arvr_interface = ARVRServer.find_interface("OVRMobile")
	if !arvr_interface:
		print("Couldn't find OVRMobile interface")
	else:
		# the init config needs to be done before arvr_interface.initialize()
		ovr_init_config = load("res://addons/godot_ovrmobile/OvrInitConfig.gdns");
		if (ovr_init_config):
			ovr_init_config = ovr_init_config.new()
			ovr_init_config.set_render_target_size_multiplier(1) # setting to 1 here is the default

		# Configure the interface init parameters.
		if arvr_interface.initialize():
			get_viewport().arvr = true
			Engine.target_fps = 72 # Quest

			# load the .gdns classes.
			ovr_display_refresh_rate = load("res://addons/godot_ovrmobile/OvrDisplayRefreshRate.gdns");
			ovr_guardian_system = load("res://addons/godot_ovrmobile/OvrGuardianSystem.gdns");
			ovr_performance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns");
			ovr_tracking_transform = load("res://addons/godot_ovrmobile/OvrTrackingTransform.gdns");
			ovr_utilities = load("res://addons/godot_ovrmobile/OvrUtilities.gdns");
			ovr_vr_api_proxy = load("res://addons/godot_ovrmobile/OvrVrApiProxy.gdns");

			# and now instance the .gdns classes for use if load was successfull
			if (ovr_display_refresh_rate): ovr_display_refresh_rate = ovr_display_refresh_rate.new()
			if (ovr_guardian_system): ovr_guardian_system = ovr_guardian_system.new()
			if (ovr_performance): ovr_performance = ovr_performance.new()
			if (ovr_tracking_transform): ovr_tracking_transform = ovr_tracking_transform.new()
			if (ovr_utilities): ovr_utilities = ovr_utilities.new()
			if (ovr_vr_api_proxy): ovr_vr_api_proxy = ovr_vr_api_proxy.new()

			print("Loaded OVRMobile")
			return true
		else:
			print("Failed to enable OVRMobile")
			return false



# many settings should only be applied once when running; this variable
# gets reset on application start or when it wakes up from sleep
var _performed_runtime_config = false

# here we can react on the android specific notifications
# reacting on NOTIFICATION_APP_RESUMED is necessary as the OVR context will get
# recreated when the Android device wakes up from sleep and then all settings wil
# need to be reapplied
func _notification(what):
	if (what == NOTIFICATION_APP_PAUSED):
		pass
	if (what == NOTIFICATION_APP_RESUMED):
		_performed_runtime_config = false # redo runtime config


func _check_and_perform_runtime_config():
	if _performed_runtime_config: return

	if (ovr_performance):
		# these are some examples of using the ovr .gdns APIs
		ovr_performance.set_clock_levels(1, 1)
		ovr_performance.set_extra_latency_mode(ovrVrApiTypes.OvrExtraLatencyMode.VRAPI_EXTRA_LATENCY_MODE_ON)
		ovr_performance.set_foveation_level(2);  # 0 == off; 4 == highest

	_performed_runtime_config = true


# example on how to smoothly move the player using the controller joystick
func _check_move(delta_t):
	var dx = $LeftTouchController.get_joystick_axis(0);
	var dy = $LeftTouchController.get_joystick_axis(1);
	var dead_zone = 0.125; # radius of the dead zone
	var move_speed = 1.0

	if (dx*dx + dy*dy > dead_zone*dead_zone):
		var view_dir = -$ARVRCamera.transform.basis.z;
		var strafe_dir = $ARVRCamera.transform.basis.x;

		view_dir.y = 0.0;
		strafe_dir.y = 0.0;

		view_dir = view_dir.normalized();
		strafe_dir = strafe_dir.normalized();

		var move_vector = Vector2(dx, dy).normalized() * move_speed;

		# to move the player in VR the position of the ARVROrigin needs to be
		# changed. As this script is attached to the ARVROrigin self is modified here
		self.transform.origin += view_dir * move_vector.y * delta_t;
		self.transform.origin += strafe_dir * move_vector.x * delta_t;


# current button mapping for the touch controller
# godot itself also exposes some of these constants via JOY_VR_* and JOY_OCULUS_*
# this enum here is to document everything in place and includes the touch event mappings
enum CONTROLLER_BUTTON {
	YB = 1,
	GRIP_TRIGGER = 2, # grip trigger pressed over threshold
	ENTER = 3, # Menu Button on left controller

	TOUCH_XA = 5,
	TOUCH_YB = 6,

	XA = 7,

	TOUCH_THUMB_UP = 10,
	TOUCH_INDEX_TRIGGER = 11,
	TOUCH_INDEX_POINTING = 12,

	THUMBSTICK = 14, # left/right thumb stick pressed
	INDEX_TRIGGER = 15, # index trigger pressed over threshold
}


# this is a function connected to the button release signal from the controller
func _on_LeftTouchController_button_pressed(button):
	if (button != CONTROLLER_BUTTON.YB): return;

	# examples on using the ovr api from gdscript
	if (ovr_guardian_system):
		print(" ovr_guardian_system.get_boundary_visible() == " + str(ovr_guardian_system.get_boundary_visible()));
		#ovr_guardian_system.request_boundary_visible(true); # make the boundary always visible

		# the oriented bounding box is the largest box that fits into the currently defined guardian
		# the return value of this function is an array with [Transform(), Vector3()] where the Vector3
		# is the scale of the box and Transform contains the position and orientation of the box.
		# The height is not yet tracked by the oculus system and will be a default value.
		print(" ovr_guardian_system.get_boundary_oriented_bounding_box() == " + str(ovr_guardian_system.get_boundary_oriented_bounding_box()));

	if (ovr_tracking_transform):
		print(" ovr_tracking_transform.get_tracking_space() == " + str(ovr_tracking_transform.get_tracking_space()));

		# you can change the tracking space to control where the default floor level is and
		# how recentring should behave.
		#ovr_guardian_system.set_tracking_space(ovrVrApiTypes.OvrTrackingSpace.VRAPI_TRACKING_SPACE_STAGE);

	if (ovr_utilities):
		print(" ovr_utilities.get_ipd() == " + str(ovr_utilities.get_ipd()));
		
		# you can access the accelerations and velocitys for the head and controllers
		# that are predicted by the Oculus VrApi via these funcitons:
		var controller_id = $LeftTouchController.controller_id;
		print(" ovr_utilities.get_controller_linear_velocity(controller_id) == " + str(ovr_utilities.get_controller_linear_velocity(controller_id)));
		print(" ovr_utilities.get_controller_linear_acceleration(controller_id) == " + str(ovr_utilities.get_controller_linear_acceleration(controller_id)));
		print(" ovr_utilities.get_controller_angular_velocity(controller_id) == " + str(ovr_utilities.get_controller_angular_velocity(controller_id)));
		print(" ovr_utilities.get_controller_angular_acceleration(controller_id) == " + str(ovr_utilities.get_controller_angular_acceleration(controller_id)));


func _on_RightTouchController_button_pressed(button):
	if (button != CONTROLLER_BUTTON.YB): return;

	if (ovr_utilities):
		# use this for fade to black for example: here we just do a color change
		ovr_utilities.set_default_layer_color_scale(Color(0.5, 0.0, 1.0, 1.0));


func _on_RightTouchController_button_release(button):
	if (button != CONTROLLER_BUTTON.YB): return;

	if (ovr_utilities):
		# reset the color to neutral again
		ovr_utilities.set_default_layer_color_scale(Color(1.0, 1.0, 1.0, 1.0));
