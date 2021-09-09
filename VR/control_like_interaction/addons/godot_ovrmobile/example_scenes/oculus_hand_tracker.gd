class_name OculusHandTracker
extends OculusTracker
# Extension of the OculusTracker class to support Oculus hands tracking.


# Current hand pinch mapping for the tracked hands
# Godot itself also exposes some of these constants via JOY_VR_* and JOY_OCULUS_*
# this enum here is to document everything in place and includes the pinch event mappings
enum FINGER_PINCH {
	MIDDLE_PINCH = 1,
	PINKY_PINCH = 2,
	INDEX_PINCH = 7,
	RING_PINCH = 15,
}

var hand_skel : Skeleton = null

# Oculus mobile APIs available at runtime.
var ovr_hand_tracking = null;
var ovr_utilities = null;

# This array is used to get the orientations from the sdk each frame (an array of Quat)
var _vrapi_bone_orientations = [];

# Remap the bone ids from the hand model to the bone orientations we get from the vrapi
var _hand_bone_mappings = [0, 23,  1, 2, 3, 4,  6, 7, 8,  10, 11, 12,  14, 15, 16, 18, 19, 20, 21];

# This is a test pose for the left hand used only on desktop so the hand has a proper position
var _test_pose_left_ThumbsUp = [Quat(0, 0, 0, 1), Quat(0, 0, 0, 1), Quat(0.321311, 0.450518, -0.055395, 0.831098),
Quat(0.263483, -0.092072, 0.093766, 0.955671), Quat(-0.082704, -0.076956, -0.083991, 0.990042),
Quat(0.085132, 0.074532, -0.185419, 0.976124), Quat(0.010016, -0.068604, 0.563012, 0.823536),
Quat(-0.019362, 0.016689, 0.8093, 0.586839), Quat(-0.01652, -0.01319, 0.535006, 0.844584),
Quat(-0.072779, -0.078873, 0.665195, 0.738917), Quat(-0.0125, 0.004871, 0.707232, 0.706854),
Quat(-0.092244, 0.02486, 0.57957, 0.809304), Quat(-0.10324, -0.040148, 0.705716, 0.699782),
Quat(-0.041179, 0.022867, 0.741938, 0.668812), Quat(-0.030043, 0.026896, 0.558157, 0.828755),
Quat(-0.207036, -0.140343, 0.018312, 0.968042), Quat(0.054699, -0.041463, 0.706765, 0.704111),
Quat(-0.081241, -0.013242, 0.560496, 0.824056), Quat(0.00276, 0.037404, 0.637818, 0.769273),
]

var _t = 0.0

onready var hand_model : Spatial = $HandModel
onready var hand_pointer : Spatial = $HandModel/HandPointer

func _ready():
	_initialize_hands()

	ovr_hand_tracking = load("res://addons/godot_ovrmobile/OvrHandTracking.gdns");
	if (ovr_hand_tracking): ovr_hand_tracking = ovr_hand_tracking.new()

	ovr_utilities = load("res://addons/godot_ovrmobile/OvrUtilities.gdns")
	if (ovr_utilities): ovr_utilities = ovr_utilities.new()


func _process(delta_t):
	_update_hand_model(hand_model, hand_skel);
	_update_hand_pointer(hand_pointer)

	# If we are on desktop or don't have hand tracking we set a debug pose on the left hand
	if (controller_id == LEFT_TRACKER_ID && !ovr_hand_tracking):
		for i in range(0, _hand_bone_mappings.size()):
			hand_skel.set_bone_pose(_hand_bone_mappings[i], Transform(_test_pose_left_ThumbsUp[i]));

	_t += delta_t;
	if (_t > 1.0):
		_t = 0.0;

		# here we print every second the state of the pinches; they are mapped at the moment
		# to the first 4 joystick axis 0==index; 1==middle; 2==ring; 3==pinky
		print("%s Pinches: %.3f %.3f %.3f %.3f" %
			 ["Left" if controller_id == LEFT_TRACKER_ID else "Right", get_joystick_axis(0), get_joystick_axis(1), get_joystick_axis(2), get_joystick_axis(3)]);


func _initialize_hands():
	hand_skel = $HandModel/ArmatureLeft/Skeleton if controller_id == LEFT_TRACKER_ID else $HandModel/ArmatureRight/Skeleton

	_clear_bone_rest(hand_skel);
	_vrapi_bone_orientations.resize(24);


func _get_tracker_label():
	return "Oculus Tracked Left Hand" if controller_id == LEFT_TRACKER_ID else "Oculus Tracked Right Hand"


# The rotations we get from the OVR sdk are absolute and not relative
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


func _update_hand_model(model : Spatial, skel: Skeleton):
	if (ovr_hand_tracking): # check if the hand tracking API was loaded
		# scale of the hand model as reported by VrApi
		var ls = ovr_hand_tracking.get_hand_scale(controller_id);
		if (ls > 0.0): model.scale = Vector3(ls, ls, ls);

		var confidence = ovr_hand_tracking.get_hand_pose(controller_id, _vrapi_bone_orientations);
		if (confidence > 0.0):
			model.visible = true;
			for i in range(0, _hand_bone_mappings.size()):
				skel.set_bone_pose(_hand_bone_mappings[i], Transform(_vrapi_bone_orientations[i]));
		else:
			model.visible = false;
		return true;
	else:
		return false;


func _update_hand_pointer(model: Spatial):
	if (ovr_hand_tracking): # check if the hand tracking API was loaded
		if (ovr_hand_tracking.is_pointer_pose_valid(controller_id)):
			model.visible = true
			model.global_transform = ovr_hand_tracking.get_pointer_pose(controller_id)
		else:
			model.visible = false


func _on_LeftHand_pinch_pressed(button):
	if (button == FINGER_PINCH.INDEX_PINCH): print("Left Index Pinching");
	if (button == FINGER_PINCH.MIDDLE_PINCH):
		print("Left Middle Pinching");
		if (ovr_utilities):
			# use this for fade to black for example: here we just do a color change
			ovr_utilities.set_default_layer_color_scale(Color(0.9, 0.85, 0.3, 1.0));

	if (button == FINGER_PINCH.PINKY_PINCH): print("Left Pinky Pinching");
	if (button == FINGER_PINCH.RING_PINCH): print("Left Ring Pinching");


func _on_RightHand_pinch_pressed(button):
	if (button == FINGER_PINCH.INDEX_PINCH): print("Right Index Pinching");
	if (button == FINGER_PINCH.MIDDLE_PINCH):
		print("Right Middle Pinching");
		if (ovr_utilities):
			# use this for fade to black for example: here we just do a color change
			ovr_utilities.set_default_layer_color_scale(Color(0.5, 0.5, 0.5, 0.7));

	if (button == FINGER_PINCH.PINKY_PINCH): print("Right Pinky Pinching");
	if (button == FINGER_PINCH.RING_PINCH): print("Right Ring Pinching");


func _on_finger_pinch_release(button):
	if (button == FINGER_PINCH.MIDDLE_PINCH):
		if (ovr_utilities):
			# use this for fade to black for example: here we just do a color change
			ovr_utilities.set_default_layer_color_scale(Color(1.0, 1.0, 1.0, 1.0));

