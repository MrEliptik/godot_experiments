# ARVROriginWithInitAndMove.[tscn/gd]
#
# This is an example implementaiton on how to initialize the Oculus Mobile Plugin (godot_ovrmobile)
# It can be used as a drop-in solution for quick testing or modified to your needs
# It shows some of the common things needed to interact with the Godot Oculus Mobile Plugin
#
# To view log/print messages use `adb logcat -s godot:* GodotOVRMobile:*` from a command prompt
extends ARVROrigin

export var physics_factor = 2.0

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
var ovr_input = null;

# Dictionary tracking the remaining duration for controllers vibration
var controllers_vibration_duration = {}

# some of the Oculus VrAPI constants are defined in this file. Have a look into it to learn more
var ovrVrApiTypes = load("res://addons/godot_ovrmobile/OvrVrApiTypes.gd").new();

# react to the worldscale changing
var was_world_scale = 1.0

var touching_rope = false
var rope_grabbed = false
var arrow_loaded = false

var max_rope_translation = Vector3(0, 2.05, 0.15)

#var max_rope_draw = 2.05
var max_rope_draw = 1

var rope_rest_pose

var ARROW_SPEED = 10

var camera_arrow_target = null
var arrow_camera = null

func _ready():
	_initialize_ovr_mobile_arvr_interface();
	
	rope_rest_pose = $"LeftTouchController/recurveBow_rigged/Armature/Skeleton".get_bone_rest(1)
	
	# Check if player is right or left handed
	# Right handed by default, but bow model is left handed
	# So we flip the distance meter
	$"LeftTouchController/recurveBow_rigged/DistanceMeter".scale.x = -1


func _process(delta_t):
	_check_and_perform_runtime_config()
	_check_move(delta_t)
	_check_worldscale()
	_update_controllers_vibration(delta_t)
	check_draw_distance()
	
	cameraFollowPoint()
	
	$CanvasLayer/Label.text = str(Engine.get_frames_per_second())

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
			Engine.iterations_per_second = 72 * physics_factor # Quest

			# load the .gdns classes.
			ovr_display_refresh_rate = load("res://addons/godot_ovrmobile/OvrDisplayRefreshRate.gdns");
			ovr_guardian_system = load("res://addons/godot_ovrmobile/OvrGuardianSystem.gdns");
			ovr_performance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns");
			ovr_tracking_transform = load("res://addons/godot_ovrmobile/OvrTrackingTransform.gdns");
			ovr_utilities = load("res://addons/godot_ovrmobile/OvrUtilities.gdns");
			ovr_vr_api_proxy = load("res://addons/godot_ovrmobile/OvrVrApiProxy.gdns");
			ovr_input = load("res://addons/godot_ovrmobile/OvrInput.gdns")

			# and now instance the .gdns classes for use if load was successfull
			if (ovr_display_refresh_rate): ovr_display_refresh_rate = ovr_display_refresh_rate.new()
			if (ovr_guardian_system): ovr_guardian_system = ovr_guardian_system.new()
			if (ovr_performance): ovr_performance = ovr_performance.new()
			if (ovr_tracking_transform): ovr_tracking_transform = ovr_tracking_transform.new()
			if (ovr_utilities): ovr_utilities = ovr_utilities.new()
			if (ovr_vr_api_proxy): ovr_vr_api_proxy = ovr_vr_api_proxy.new()
			if (ovr_input): ovr_input = ovr_input.new()

			# Connect to the plugin signals
			_connect_to_signals()

			print("Loaded OVRMobile")
			return true
		else:
			print("Failed to enable OVRMobile")
			return false

func _connect_to_signals():
	if Engine.has_singleton("OVRMobile"):
		var singleton = Engine.get_singleton("OVRMobile")
		print("Connecting to OVRMobile signals")
		singleton.connect("HeadsetMounted", self, "_on_headset_mounted")
		singleton.connect("HeadsetUnmounted", self, "_on_headset_unmounted")
		singleton.connect("InputFocusGained", self, "_on_input_focus_gained")
		singleton.connect("InputFocusLost", self, "_on_input_focus_lost")
		singleton.connect("EnterVrMode", self, "_on_enter_vr_mode")
		singleton.connect("LeaveVrMode", self, "_on_leave_vr_mode")
	else:
		print("Unable to load OVRMobile singleton...")

func _on_headset_mounted():
	print("VR headset mounted")

func _on_headset_unmounted():
	print("VR headset unmounted")

func _on_input_focus_gained():
	print("Input focus gained")

func _on_input_focus_lost():
	print("Input focus lost")

func _on_enter_vr_mode():
	print("Entered Oculus VR mode")

func _on_leave_vr_mode():
	print("Left Oculus VR mode")

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


func _start_controller_vibration(controller, duration, rumble_intensity):
	print("Starting vibration of controller " + str(controller) + " for " + str(duration) + "  at " + str(rumble_intensity))
	controllers_vibration_duration[controller.controller_id] = duration
	controller.set_rumble(rumble_intensity)

func _update_controllers_vibration(delta_t):
	# Check if there are any controllers currently vibrating
	if (controllers_vibration_duration.empty()):
		return

	# Update the remaining vibration duration for each controller
	for i in ARVRServer.get_tracker_count():
		var tracker = ARVRServer.get_tracker(i)
		if (controllers_vibration_duration.has(tracker.get_tracker_id())):
			var remaining_duration = controllers_vibration_duration[tracker.get_tracker_id()] - (delta_t * 1000)
			if (remaining_duration < 0):
				controllers_vibration_duration.erase(tracker.get_tracker_id())
				tracker.set_rumble(0)
			else:
				controllers_vibration_duration[tracker.get_tracker_id()] = remaining_duration

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
	#print("Primary controller id: " + str(ovr_input.get_primary_controller_id()))

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
			var controller_id = $LeftTouchController.controller_id;
			print(" ovr_utilities.get_controller_linear_velocity(controller_id) == " + str(ovr_utilities.get_controller_linear_velocity(controller_id)));
			print(" ovr_utilities.get_controller_linear_acceleration(controller_id) == " + str(ovr_utilities.get_controller_linear_acceleration(controller_id)));
			print(" ovr_utilities.get_controller_angular_velocity(controller_id) == " + str(ovr_utilities.get_controller_angular_velocity(controller_id)));
			print(" ovr_utilities.get_controller_angular_acceleration(controller_id) == " + str(ovr_utilities.get_controller_angular_acceleration(controller_id)));

	if (button == CONTROLLER_BUTTON.XA):
		_start_controller_vibration($LeftTouchController, 40, 0.5)

func _on_RightTouchController_button_pressed(button):
	if (button == CONTROLLER_BUTTON.XA):
		# Reset camera 
		resetCamera()
		
	if button == CONTROLLER_BUTTON.INDEX_TRIGGER and touching_rope:
		rope_grabbed = true


func _on_RightTouchController_button_release(button):	
	if button == CONTROLLER_BUTTON.INDEX_TRIGGER and rope_grabbed:
		rope_grabbed = false
		var skel = $"LeftTouchController/recurveBow_rigged/Armature/Skeleton"	
		var bone_rest = skel.get_bone_rest(1)
		# TODO: interpolate transform to make it smoother
		skel.set_bone_pose(1, Transform())
		$"LeftTouchController/recurveBow_rigged/ArrowPlacingArea/CollisionShape".disabled = false
		
		if $LeftTouchController/ArrowPoint.get_child_count() > 0:
			#TODO: calculate force based on how far the rope is drawn
			# Launch arrow
			
			#arrow_camera = ARVRCamera.new()
			#add_child(arrow_camera)
			#$ARVRCamera.current = false
			#arrow_camera.current = true
			#move_child(arrow_camera, 0)
			cameraFollowPoint()
			Engine.time_scale = 0.025
			camera_arrow_target = $LeftTouchController/ArrowPoint.get_child(0).get_node("Position3D")
			
			$LeftTouchController/ArrowPoint.get_child(0).get_node("Trail3D").visible = true
			$LeftTouchController/ArrowPoint.get_child(0).let_go(-$"LeftTouchController/ArrowPoint".global_transform.basis.z  * ARROW_SPEED)
			$LeftTouchController/recurveBow_rigged/AudioStreamPlayer4.play()
			$Timer.start()
			
		
func _check_worldscale():
	if was_world_scale != world_scale:
		was_world_scale = world_scale
		print("world_scale: ", world_scale)
		var inv_world_scale = 1.0 / was_world_scale
		var controller_scale = Vector3(inv_world_scale, inv_world_scale, inv_world_scale)
		$"LeftTouchController/left-controller".scale = controller_scale
		$"RightTouchController/right-controller".scale = -controller_scale
		
func check_draw_distance():
	if rope_grabbed:
		var skel = $"LeftTouchController/recurveBow_rigged/Armature/Skeleton"
		var dist = $"RightTouchController".global_transform.origin.distance_to($"LeftTouchController/recurveBow_rigged/RopePosition".global_transform.origin)
		
		if dist > 0.1:
			pass
			#$LeftTouchController/recurveBow_rigged/AudioStreamPlayer2.play()
		
		var bone_transf = Transform()
		bone_transf.origin.y = dist*4 # need to multiply by 4 because we scaled to 0.25
		skel.set_bone_pose(1, bone_transf)
		
		if $"LeftTouchController/ArrowPoint".get_child_count() > 0 and $"LeftTouchController/ArrowPoint".get_child(0).translation.z < max_rope_draw:
			$"LeftTouchController/ArrowPoint".get_child(0).translation.z = dist
			if $"LeftTouchController/ArrowPoint".get_child(0).translation.z > max_rope_draw: 
				$"LeftTouchController/ArrowPoint".get_child(0).translation.z = max_rope_draw

func cameraFollowPoint():
	if camera_arrow_target:
		$LeftTouchController.visible = false
		$RightTouchController.visible = false
		global_transform.origin = camera_arrow_target.global_transform.origin
		global_transform.origin.x += 0.505
		look_at(camera_arrow_target.global_transform.origin, Vector3.UP)
		
func resetCamera():
	print("reset camera")
	camera_arrow_target = null
	global_transform = get_parent().get_parent().get_node("CameraResetPos").global_transform
	$LeftTouchController.visible = true
	$RightTouchController.visible = true
	Engine.time_scale = 1.0

func _on_InteractionArea_area_entered(area):
	if area.name == "RopeArea":
		touching_rope = true

func _on_InteractionArea_area_exited(area):
	if area.name == "RopeArea":
		touching_rope = false

func _on_recurveBow_rigged_body_entered(body):
	# The body is pickable and we have no arrow under arrow point
	if body.has_method('is_picked_up') and $LeftTouchController/ArrowPoint.get_child_count() == 0 and !arrow_loaded:
		if !body.is_picked_up():
			$LeftTouchController/recurveBow_rigged/AudioStreamPlayer.play()
			_start_controller_vibration($LeftTouchController, 40, 0.5)
			body.pick_up($LeftTouchController/ArrowPoint)
			arrow_loaded = true
			print("Body picked up:", body, arrow_loaded)
			print("Arrow loaded")
			$"LeftTouchController/recurveBow_rigged/ArrowPlacingArea/CollisionShape".disabled = true			
			
func _on_Timer_timeout():
	# Arrow is launched, we can detect collision again
	arrow_loaded = false
	$"LeftTouchController/recurveBow_rigged/ArrowPlacingArea/CollisionShape".disabled = false
