# Attach this script to any rigid body you want to be grabbable
# by the Feature_RigidBodyGrab
extends RigidBody

class_name OQClass_GrabbableRigidBody


var target_node = null;
var delta_orientation = Basis();
var delta_position = Vector3();
var is_grabbed := false

export var is_grabbable := true

var last_reported_collision_pos : Vector3 = Vector3(0,0,0);

var _orig_can_sleep := true;

var _grab_type := -1;

var _release_next_physics_step := false;
var _cached_linear_velocity := Vector3(0,0,0); # required for kinematic grab
var _cached_angular_velocity := Vector3(0,0,0);

func grab_init(node, grab_type: int) -> void:
	target_node = node
	_grab_type = grab_type
	
	is_grabbed = true
	sleeping = false;
	_orig_can_sleep = can_sleep;
	can_sleep = false;

func _release():
	is_grabbed = false
	target_node = null
	can_sleep = _orig_can_sleep;


func grab_release() -> void:
	if _grab_type == vr.GrabTypes.KINEMATIC:
		_release_next_physics_step = true;
		_cached_linear_velocity = linear_velocity;
		_cached_angular_velocity = angular_velocity;
	else:
		_release();
	


func orientation_follow(state, current_basis : Basis, target_basis : Basis) -> void:
	var delta : Basis = target_basis * current_basis.inverse();
	
	var q = Quat(delta);
	var axis = Vector3(q.x, q.y, q.z);

	if (axis.length_squared() > 0.0001):  # bullet fuzzyzero() is < FLT_EPSILON (1E-5)
		axis = axis.normalized();
		var angle = 2.0 * acos(q.w);
		state.set_angular_velocity(axis * (angle / (state.get_step())));
	else:
		state.set_angular_velocity(Vector3(0,0,0));



func position_follow(state, current_position, target_position) -> void:
	var dir = target_position - current_position;
	state.set_linear_velocity(dir / state.get_step());


func _integrate_forces(state):
	if (!is_grabbed): return;
	
	if (_release_next_physics_step):
		_release_next_physics_step = false;
		if _grab_type == vr.GrabTypes.KINEMATIC:
			state.set_linear_velocity(_cached_linear_velocity);
			state.set_angular_velocity(_cached_angular_velocity);
		_release();
		return;
	
	# TODO: it would be better to use == Feature_RigidBodyGrab.GrabTypes.KINEMATIC
	# but this leads to an odd cyclic reference error
	# related to this bug: https://github.com/godotengine/godot/issues/21461
	if _grab_type == vr.GrabTypes.KINEMATIC:
		return;

	if _grab_type == vr.GrabTypes.HINGEJOINT:
		return;
	
	if (_grab_type == vr.GrabTypes.VELOCITY):
		if (!target_node): return;
		var target_basis =  target_node.get_global_transform().basis * delta_orientation;
		var target_position = target_node.get_global_transform().origin# + target_basis.xform(delta_position);
		position_follow(state, get_global_transform().origin, target_position);
		orientation_follow(state, get_global_transform().basis, target_basis);
