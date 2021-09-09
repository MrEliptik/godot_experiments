class_name OculusTouchController
extends OculusTracker
# Extension of the OculusTracker class to support the Oculus Touch controllers.


# Current button mapping for the touch controller
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

# Oculus mobile APIs available at runtime.
var ovr_guardian_system = null;
var ovr_input = null;
var ovr_tracking_transform = null;
var ovr_utilities = null;

# react to the worldscale changing
var _was_world_scale = 1.0

# Dictionary tracking the remaining duration for controllers vibration
var _controllers_vibration_duration = {}

onready var camera : ARVRCamera = origin.get_node("ARVRCamera")

func _ready():
	ovr_input = load("res://addons/godot_ovrmobile/OvrInput.gdns")
	if (ovr_input): ovr_input = ovr_input.new()

	ovr_guardian_system = load("res://addons/godot_ovrmobile/OvrGuardianSystem.gdns")
	if (ovr_guardian_system): ovr_guardian_system = ovr_guardian_system.new()

	ovr_tracking_transform = load("res://addons/godot_ovrmobile/OvrTrackingTransform.gdns")
	if (ovr_tracking_transform): ovr_tracking_transform = ovr_tracking_transform.new()

	ovr_utilities = load("res://addons/godot_ovrmobile/OvrUtilities.gdns")
	if (ovr_utilities): ovr_utilities = ovr_utilities.new()


func _process(delta_t):
	_check_move(delta_t)
	_check_worldscale(origin.world_scale)
	_update_controllers_vibration(delta_t)


func _get_tracker_label():
	return "Oculus Touch Left Controller" if controller_id == LEFT_TRACKER_ID else "Oculus Touch Right Controller"


# example on how to smoothly move the player using the controller joystick
func _check_move(delta_t):
	if (controller_id != LEFT_TRACKER_ID):
		return

	var dx = get_joystick_axis(0);
	var dy = get_joystick_axis(1);
	var dead_zone = 0.125; # radius of the dead zone
	var move_speed = 1.0

	if (dx*dx + dy*dy > dead_zone*dead_zone):
		var view_dir = -camera.transform.basis.z;
		var strafe_dir = camera.transform.basis.x;

		view_dir.y = 0.0;
		strafe_dir.y = 0.0;

		view_dir = view_dir.normalized();
		strafe_dir = strafe_dir.normalized();

		var move_vector = Vector2(dx, dy).normalized() * move_speed;

		# to move the player in VR the position of the ARVROrigin needs to be
		# changed. As this script is attached to the ARVROrigin self is modified here
		origin.transform.origin += view_dir * move_vector.y * delta_t;
		origin.transform.origin += strafe_dir * move_vector.x * delta_t;


func _start_controller_vibration(duration, rumble_intensity):
	print("Starting vibration of controller " + str(self) + " for " + str(duration) + "  at " + str(rumble_intensity))
	_controllers_vibration_duration[controller_id] = duration
	set_rumble(rumble_intensity)


func _update_controllers_vibration(delta_t):
	# Check if there are any controllers currently vibrating
	if (_controllers_vibration_duration.empty()):
		return

	# Update the remaining vibration duration for each controller
	for i in ARVRServer.get_tracker_count():
		var tracker = ARVRServer.get_tracker(i)
		if (_controllers_vibration_duration.has(tracker.get_tracker_id())):
			var remaining_duration = _controllers_vibration_duration[tracker.get_tracker_id()] - (delta_t * 1000)
			if (remaining_duration < 0):
				_controllers_vibration_duration.erase(tracker.get_tracker_id())
				tracker.set_rumble(0)
			else:
				_controllers_vibration_duration[tracker.get_tracker_id()] = remaining_duration


# this is a function connected to the button release signal from the controller
func _on_LeftTouchController_button_pressed(button):
	print("Primary controller id: " + str(ovr_input.get_primary_controller_id()))

	if (button == CONTROLLER_BUTTON.YB):
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
			print(" ovr_utilities.get_controller_linear_velocity(controller_id) == " + str(ovr_utilities.get_controller_linear_velocity(controller_id)));
			print(" ovr_utilities.get_controller_linear_acceleration(controller_id) == " + str(ovr_utilities.get_controller_linear_acceleration(controller_id)));
			print(" ovr_utilities.get_controller_angular_velocity(controller_id) == " + str(ovr_utilities.get_controller_angular_velocity(controller_id)));
			print(" ovr_utilities.get_controller_angular_acceleration(controller_id) == " + str(ovr_utilities.get_controller_angular_acceleration(controller_id)));

	if (button == CONTROLLER_BUTTON.XA):
		_start_controller_vibration(40, 0.5)


func _on_RightTouchController_button_pressed(button):
	print("Primary controller id: " + str(ovr_input.get_primary_controller_id()))

	if (button == CONTROLLER_BUTTON.YB):
		if (ovr_utilities):
			# use this for fade to black for example: here we just do a color change
			ovr_utilities.set_default_layer_color_scale(Color(0.5, 0.0, 1.0, 1.0));

	if (button == CONTROLLER_BUTTON.XA):
		_start_controller_vibration(40, 0.5)


func _on_RightTouchController_button_release(button):
	if (button != CONTROLLER_BUTTON.YB): return;

	if (ovr_utilities):
		# reset the color to neutral again
		ovr_utilities.set_default_layer_color_scale(Color(1.0, 1.0, 1.0, 1.0));


func _check_worldscale(world_scale):
	if _was_world_scale != world_scale:
		_was_world_scale = world_scale
		var inv_world_scale = 1.0 / _was_world_scale
		var controller_scale = Vector3(inv_world_scale, inv_world_scale, inv_world_scale)
		$TouchControllerModel.scale = -controller_scale if controller_id == RIGHT_TRACKER_ID else controller_scale
