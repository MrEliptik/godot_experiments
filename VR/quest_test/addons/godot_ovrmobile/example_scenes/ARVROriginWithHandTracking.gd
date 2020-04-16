extends ARVROrigin

var ovr_init_config = null;

var ovr_performance = null;
var ovr_display_refresh_rate = null;
var ovr_guardian_system = null;
var ovr_tracking_transform = null;
var ovr_utilities = null;
var ovr_vr_api_proxy = null;

var ovr_hand_tracking = null;

var ovrVrApiTypes = load("res://addons/godot_ovrmobile/OvrVrApiTypes.gd").new();

onready var left_hand : ARVRController = $LeftHand;
onready var right_hand : ARVRController = $RightHand;
onready var left_model : Spatial = $LeftHand/left_hand_model;
onready var right_model : Spatial = $RightHand/right_hand_model;
onready var left_skel : Skeleton =  $LeftHand/left_hand_model/ArmatureLeft/Skeleton;
onready var right_skel : Skeleton =  $RightHand/right_hand_model/ArmatureRight/Skeleton;

# this array is used to get the orientations from the sdk each frame (an array of Quat)
var _vrapi_bone_orientations = [];

# remap the bone ids from the hand model to the bone orientations we get from the vrapi
var _hand_bone_mappings = [0, 23,  1, 2, 3, 4,  6, 7, 8,  10, 11, 12,  14, 15, 16, 18, 19, 20, 21];


# This is a test pose for the left hand used only on desktop so the hand has a proper position
var test_pose_left_ThumbsUp = [Quat(0, 0, 0, 1), Quat(0, 0, 0, 1), Quat(0.321311, 0.450518, -0.055395, 0.831098),
Quat(0.263483, -0.092072, 0.093766, 0.955671), Quat(-0.082704, -0.076956, -0.083991, 0.990042),
Quat(0.085132, 0.074532, -0.185419, 0.976124), Quat(0.010016, -0.068604, 0.563012, 0.823536),
Quat(-0.019362, 0.016689, 0.8093, 0.586839), Quat(-0.01652, -0.01319, 0.535006, 0.844584),
Quat(-0.072779, -0.078873, 0.665195, 0.738917), Quat(-0.0125, 0.004871, 0.707232, 0.706854),
Quat(-0.092244, 0.02486, 0.57957, 0.809304), Quat(-0.10324, -0.040148, 0.705716, 0.699782),
Quat(-0.041179, 0.022867, 0.741938, 0.668812), Quat(-0.030043, 0.026896, 0.558157, 0.828755),
Quat(-0.207036, -0.140343, 0.018312, 0.968042), Quat(0.054699, -0.041463, 0.706765, 0.704111),
Quat(-0.081241, -0.013242, 0.560496, 0.824056), Quat(0.00276, 0.037404, 0.637818, 0.769273),
]

# the rotations we get from the OVR sdk are absolute and not relative
# to the rest pose we have in the model; so we clear them here to be
# able to use set pose
# This is more like a workaround then a clean solution but allows to use 
# the hand model from the sample without major modifications
func _clear_bone_rest(skel):
	for i in range(0, skel.get_bone_count()):
		var bone_rest = skel.get_bone_rest(i);
		skel.set_bone_pose(i, Transform(bone_rest.basis)); # use the original rest as pose
		bone_rest.basis = Basis();
		skel.set_bone_rest(i, bone_rest);


func _update_hand_model(hand: ARVRController, model : Spatial, skel: Skeleton):
	if (ovr_hand_tracking): # check if the hand tracking API was loaded
		# scale of the hand model as reported by VrApi
		var ls = ovr_hand_tracking.get_hand_scale(hand.controller_id);
		if (ls > 0.0): model.scale = Vector3(ls, ls, ls);
		
		var confidence = ovr_hand_tracking.get_hand_pose(hand.controller_id, _vrapi_bone_orientations);
		if (confidence > 0.0):
			model.visible = true;
			for i in range(0, _hand_bone_mappings.size()):
				skel.set_bone_pose(_hand_bone_mappings[i], Transform(_vrapi_bone_orientations[i]));
		else:
			model.visible = false;
		return true;
	else:
		return false;

func _ready():
	_initialize_ovr_mobile_arvr_interface();
	
	_clear_bone_rest(left_skel);
	_clear_bone_rest(right_skel);
		
	_vrapi_bone_orientations.resize(24);
	

var t = 0.0;
func _process(delta_t):
	_check_and_perform_runtime_config()
	
	_update_hand_model(left_hand, left_model, left_skel);
	_update_hand_model(right_hand, right_model, right_skel);
	
	# If we are on desktop or don't have hand tracking we set a debug pose on the left hand
	if (!ovr_hand_tracking):
		for i in range(0, _hand_bone_mappings.size()):
			left_skel.set_bone_pose(_hand_bone_mappings[i], Transform(test_pose_left_ThumbsUp[i]));
	
	
	
	t += delta_t;
	if (t > 1.0):
		t = 0.0;
		
		# here we print every second the state of the pinches; they are mapped at the moment
		# to the first 4 joystick axis 0==index; 1==middle; 2==ring; 3==pinky
		print("Left Pinches: %.3f %.3f %.3f %.3f; Right Pinches %.3f %.3f %.3f %.3f" % 
			 [left_hand.get_joystick_axis(0), left_hand.get_joystick_axis(1), left_hand.get_joystick_axis(2), left_hand.get_joystick_axis(3),
			  right_hand.get_joystick_axis(0), right_hand.get_joystick_axis(1), right_hand.get_joystick_axis(2), right_hand.get_joystick_axis(3)]);

	
				



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
			ovr_hand_tracking = load("res://addons/godot_ovrmobile/OvrHandTracking.gdns");
			ovr_vr_api_proxy = load("res://addons/godot_ovrmobile/OvrVrApiProxy.gdns");

			# and now instance the .gdns classes for use if load was successfull
			if (ovr_display_refresh_rate): ovr_display_refresh_rate = ovr_display_refresh_rate.new()
			if (ovr_guardian_system): ovr_guardian_system = ovr_guardian_system.new()
			if (ovr_performance): ovr_performance = ovr_performance.new()
			if (ovr_tracking_transform): ovr_tracking_transform = ovr_tracking_transform.new()
			if (ovr_utilities): ovr_utilities = ovr_utilities.new()
			if (ovr_hand_tracking): ovr_hand_tracking = ovr_hand_tracking.new()
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
		pass;

	_performed_runtime_config = true


# the pinch press gestures are mapped to button presses of the ARVRController
# they are mapped at the moment to the A/B X/Y and grip/index trigger presses
func _on_LeftHand_pinch_pressed(button):
	if (button == 7): print("Left Index Pinching");
	if (button == 1): print("Left Middle Pinching");
	if (button == 2): print("Left Pinky Pinching");
	if (button == 15): print("Left Ring Pinching");


func _on_RightHand_pinch_pressed(button):
	if (button == 7): print("Right Index Pinching");
	if (button == 1): print("Right Middle Pinching");
	if (button == 2): print("Right Pinky Pinching");
	if (button == 15): print("Right Ring Pinching");

