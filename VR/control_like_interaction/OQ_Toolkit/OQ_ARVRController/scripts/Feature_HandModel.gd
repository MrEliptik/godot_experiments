# Feature_HandModel_[Left|Right]
# This script contains the logic to update the hand model pose from the VrApi
# and also contains some helper functions
extends Spatial

onready var palm_marker = $PalmMarker;
onready var grab_marker = $GrabMarker;
onready var ui_marker = $UIMarker;

var hand : ARVRController = null;
var model : Spatial = null;
var skel : Skeleton = null; 

var tracking_confidence = 1.0;

# the VrApi has at the moment no velocity tracking so we average sth. ourselves for now
# this variable is used/returned in the method OQ_ARVRController.gd get_linear_velocity()
var average_velocity = Vector3(0, 0, 0);

const _velocity_buffer_size := 16;
const _velocity_update_confidence_threshold = 0.5;
var _last_velocity_position := Vector3(0,0,0)
var _velocity_buffer_pos := 0;
var _velocity_buffer := [];

# currently the VrAPI seems not to give the velocity of the hands. This
# function averages the movement over several frames to give a rough estimate
# of the hand velocity
func _track_average_velocity(_dt):
	# workaround for https://github.com/NeoSpark314/godot_oculus_quest_toolkit/issues/5
	# since we divide by _dt; so far I did not figure out in which cases this actually happens
	if (_dt <= 0.0): return;
	
	if _velocity_buffer.size() == 0:
		_velocity_buffer.resize(_velocity_buffer_size);
		for i in range(0, _velocity_buffer_size): _velocity_buffer[i] = Vector3(0,0,0);
		_last_velocity_position = global_transform.origin;
	
	var v = global_transform.origin - _last_velocity_position;
	if (tracking_confidence < _velocity_update_confidence_threshold): # no update
		v = Vector3(0, 0, 0); # assume no movement
	
	_velocity_buffer[_velocity_buffer_pos] = v;
	_velocity_buffer_pos = (_velocity_buffer_pos + 1)%_velocity_buffer_size;
	
	average_velocity = Vector3(0, 0, 0);
	for i in range(0, _velocity_buffer_size): 
		average_velocity += _velocity_buffer[i]
		
	average_velocity = average_velocity * (1.0 / (_dt * _velocity_buffer_size));
	
	_last_velocity_position = global_transform.origin;



# this array is used to get the orientations from the sdk each frame (an array of Quat)
var _vrapi_bone_orientations = [];

enum ovrHandFingers {
	Thumb		= 0,
	Index		= 1,
	Middle		= 2,
	Ring		= 3,
	Pinky		= 4,
	Max,
	EnumSize = 0x7fffffff
};

enum ovrHandBone {
	Invalid						= -1,
	WristRoot 					= 0,	# root frame of the hand, where the wrist is located
	ForearmStub					= 1,	# frame for user's forearm
	Thumb0						= 2,	# thumb trapezium bone
	Thumb1						= 3,	# thumb metacarpal bone
	Thumb2						= 4,	# thumb proximal phalange bone
	Thumb3						= 5,	# thumb distal phalange bone
	Index1						= 6,	# index proximal phalange bone
	Index2						= 7,	# index intermediate phalange bone
	Index3						= 8,	# index distal phalange bone
	Middle1						= 9,	# middle proximal phalange bone
	Middle2						= 10,	# middle intermediate phalange bone
	Middle3						= 11,	# middle distal phalange bone
	Ring1						= 12,	# ring proximal phalange bone
	Ring2						= 13,	# ring intermediate phalange bone
	Ring3						= 14,	# ring distal phalange bone
	Pinky0						= 15,	# pinky metacarpal bone
	Pinky1						= 16,	# pinky proximal phalange bone
	Pinky2						= 17,	# pinky intermediate phalange bone
	Pinky3						= 18,	# pinky distal phalange bone
	MaxSkinnable				= 19,

	# Bone tips are position only. They are not used for skinning but useful for hit-testing.
	# NOTE: ThumbTip == MaxSkinnable since the extended tips need to be contiguous
	ThumbTip					= 19 + 0,	# tip of the thumb
	IndexTip					= 19 + 1,	# tip of the index finger
	MiddleTip					= 19 + 2,	# tip of the middle finger
	RingTip						= 19 + 3,	# tip of the ring finger
	PinkyTip					= 19 + 4,	# tip of the pinky
	Max 						= 19 + 5,
	EnumSize 					= 0x7fff
};

const _ovrHandFingers_Bone1Start = [ovrHandBone.Thumb1, ovrHandBone.Index1, ovrHandBone.Middle1, ovrHandBone.Ring1,ovrHandBone.Pinky1];


# we need to remap the bone ids from the hand model to the bone orientations we get from the vrapi and the inverse
# This is only for the actual bones and skips the tips (vrapi 19-23) as they do not need to be updated I think
const _vrapi2hand_bone_map = [0, 23,  1, 2, 3, 4,  6, 7, 8,  10, 11, 12,  14, 15, 16, 18, 19, 20, 21];
# inverse mapping to get from the godot hand bone ids to the vrapi bone ids
const _hand2vrapi_bone_map = [0, 2, 3, 4, 5,19, 6, 7, 8, 20,  9, 10, 11, 21, 12, 13, 14, 22, 15, 16, 17, 18, 23, 1];

# we need the inverse neutral pose to compute the estimates for gesture detection
var _vrapi_inverse_neutral_pose = []; # this is filled when clearing the rest pose

# This is a test pose for the left hand used only on desktop so the hand has a proper position
const test_pose_left_ThumbsUp = [Quat(0, 0, 0, 1), Quat(0, 0, 0, 1), Quat(0.321311, 0.450518, -0.055395, 0.831098),
Quat(0.263483, -0.092072, 0.093766, 0.955671), Quat(-0.082704, -0.076956, -0.083991, 0.990042),
Quat(0.085132, 0.074532, -0.185419, 0.976124), Quat(0.010016, -0.068604, 0.563012, 0.823536),
Quat(-0.019362, 0.016689, 0.8093, 0.586839), Quat(-0.01652, -0.01319, 0.535006, 0.844584),
Quat(-0.072779, -0.078873, 0.665195, 0.738917), Quat(-0.0125, 0.004871, 0.707232, 0.706854),
Quat(-0.092244, 0.02486, 0.57957, 0.809304), Quat(-0.10324, -0.040148, 0.705716, 0.699782),
Quat(-0.041179, 0.022867, 0.741938, 0.668812), Quat(-0.030043, 0.026896, 0.558157, 0.828755),
Quat(-0.207036, -0.140343, 0.018312, 0.968042), Quat(0.054699, -0.041463, 0.706765, 0.704111),
Quat(-0.081241, -0.013242, 0.560496, 0.824056), Quat(0.00276, 0.037404, 0.637818, 0.769273),
]

func _ready():
	hand = get_parent();
	if (not hand is ARVRController):
		vr.log_error(" in Feature_HandModel: parent not ARVRController.");
		
	model = get_child(0);
	if (model == null):
		vr.log_error(" in Feature_HandModel: expected hand model to be child 0");
		
	skel = model.get_child(0).get_child(0); # this is specific to the .gltf file that was exported
	if (skel == null):
		vr.log_error(" in Feature_HandModel: could not get skeleton of hand");
		
	_vrapi_bone_orientations.resize(24);
	_clear_bone_rest(skel);
	
	# apply a start pose
	#for i in range(0, _vrapi2hand_bone_map.size()):
	#	skel.set_bone_pose(_vrapi2hand_bone_map[i], Transform(test_pose_left_ThumbsUp[i]));


func _get_bone_angle_diff(ovrHandBone_id):
	var quat_diff = _vrapi_bone_orientations[ovrHandBone_id] * _vrapi_inverse_neutral_pose[ovrHandBone_id];
	var a = acos(clamp(quat_diff.w, -1.0, 1.0));
	return rad2deg(a);

# For simple gesture detection we can just look at the state of the fingers
# and distinguish between bent and straight
enum SimpleFingerState {
	Bent = 0,
	Straight = 1,
	Inbetween = 2,
}

# this is a very basic heuristic to detect if a finger is straight or not.
# It is a bit unprecise on the thumb and pinky but overall is enough for very simple
# gesture detection; it uses the accumulated angle of the 3 bones in each finger
func get_finger_state_estimate(finger):
	var angle = 0.0;
	angle += _get_bone_angle_diff(_ovrHandFingers_Bone1Start[finger]+0);
	angle += _get_bone_angle_diff(_ovrHandFingers_Bone1Start[finger]+1);
	angle += _get_bone_angle_diff(_ovrHandFingers_Bone1Start[finger]+2);
	
	# !!TODO: thresholds need some finetuning here
	if (finger == ovrHandFingers.Thumb):
		if (angle <= 30): return SimpleFingerState.Straight;
		if (angle >= 35): return SimpleFingerState.Bent; # very low threshold here...
	elif (finger == ovrHandFingers.Pinky):
		if (angle <= 40): return SimpleFingerState.Straight;
		if (angle >= 60): return SimpleFingerState.Bent;
	else:
		if (angle <= 35): return SimpleFingerState.Straight;
		if (angle >= 75): return SimpleFingerState.Bent;
	return SimpleFingerState.Inbetween;

# for now we put the gestures in a dicitonary and use deciaml values as key
# this is a bit clunky and will change in the future with a more elegant solution I hope
# (but it allows to add gestures at runtime by adding them to this dicitonary :-)
var SimpleGestures = {
	00000 : "Fist",
	00001 : "One",
	00011 : "Two",
	00111 : "Three",
	01111 : "Four",
	11111 : "Five",
	00010 : "Point",
	00100 : "FYou",
	00110 : "V",
	10010 : "Rock",
	10011 : "Spiderman",
	11120 : "OK",
	10001 : "Shaka",
}

# this will compute the finger state and check if the gesture is in the SimpleGestures
# dictionary. If it is not found it returns the empty string

var _last_detected_gesture = "";

func detect_simple_gesture():
	
	# this is to make sure we do keep the state when we loose tracking
	if (tracking_confidence <= 0.5): return _last_detected_gesture;
	
	var m = 1;
	var gesture = 0;
	for i in range(0, 5):
		var finger_state = get_finger_state_estimate(i);
		gesture += m * finger_state;
		m *= 10; # ??? No idea what I'm thinking here to solve it this way... needs some less stupid solution in the future
	
	_last_detected_gesture = "";
	if SimpleGestures.has(int(gesture)):
		_last_detected_gesture = SimpleGestures[int(gesture)];
		
		
	#_debug_show_finger_estimate();

	return _last_detected_gesture;


func _debug_show_finger_estimate():
	vr.show_dbg_info(name, "Thumb: %d, Index: %d, Middle: %d, Ring: %d, Pinky: %d" % [
		get_finger_state_estimate(ovrHandFingers.Thumb),
		get_finger_state_estimate(ovrHandFingers.Index),
		get_finger_state_estimate(ovrHandFingers.Middle),
		get_finger_state_estimate(ovrHandFingers.Ring),
		get_finger_state_estimate(ovrHandFingers.Pinky),
		]);

func _process(_dt):
	if (vr.inVR):
		_update_hand_model(hand, model, skel);
	_track_average_velocity(_dt);

# the rotations we get from the OVR sdk are absolute and not relative
# to the rest pose we have in the model; so we clear them here to be
# able to use set pose
# This is more like a workaround then a clean solution but allows to use 
# the hand model from the sample without major modifications
func _clear_bone_rest(skeleton : Skeleton):
	_vrapi_inverse_neutral_pose.resize(skeleton.get_bone_count());
	for i in range(0, skeleton.get_bone_count()):
		var bone_rest = skeleton.get_bone_rest(i);
		
		skeleton.set_bone_pose(i, Transform(bone_rest.basis)); # use the loaded rest as start pose
		
		_vrapi_inverse_neutral_pose[_hand2vrapi_bone_map[i]] = bone_rest.basis.get_rotation_quat().inverse();
		
		# we fill this array here also with the rest pose so on Desktop we still have a valid array
		_vrapi_bone_orientations[_hand2vrapi_bone_map[i]]  = bone_rest.basis.get_rotation_quat();
		
		bone_rest.basis = Basis(); # clear the rotation of the rest pose
		skeleton.set_bone_rest(i, bone_rest); # and set this as the rest pose for the skeleton


# Query the VrApi hand pose state and update the hand model bone pose
func _update_hand_model(param_hand: ARVRController, param_model : Spatial, skeleton: Skeleton):
	# we check to level visibility here for the node to not update
	# when the application (or the OQ_XXXController) set it invisible
	if (vr.ovrHandTracking && visible): # check if the hand tracking API was loaded
		# scale of the hand model as reported by VrApi
		var ls = vr.ovrHandTracking.get_hand_scale(param_hand.controller_id);
		if (ls > 0.0): param_model.scale = Vector3(ls, ls, ls);
		
		tracking_confidence = vr.ovrHandTracking.get_hand_pose(param_hand.controller_id, _vrapi_bone_orientations);
		if (tracking_confidence > 0.0):
			param_model.visible = true;
			for i in range(0, _vrapi2hand_bone_map.size()):
				skeleton.set_bone_pose(_vrapi2hand_bone_map[i], Transform(_vrapi_bone_orientations[i]));
		else:
			param_model.visible = false;
		return true;
	else:
		return false;
