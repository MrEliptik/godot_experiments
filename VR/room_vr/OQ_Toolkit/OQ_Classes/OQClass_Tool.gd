extends Spatial

class_name OQClass_Tool

export(NodePath) var root_grabbable_part = null

var isGrabbed: bool = false

var _root_grabbable_part: OQClass_GrabbableToolPart = null

var _controllers_grabbing = []
var _controllers_to_parts = {}
var _controller_grab_transforms = {}

var _placeholder_rigidbody: RigidBody = null
var _parts = []

func _ready():
	# Add all our children to a list of tool parts.
	for child in get_children():
		if not child is OQClass_GrabbableToolPart:
			vr.log_warning("Child of tool is not grabbable tool part.")
		child.parent_tool = self
		_parts.append(child)
	# If we have a root tool part, store it too.
	if _root_grabbable_part != null:
		_root_grabbable_part = find_node(root_grabbable_part)

# warning-ignore:unused_argument
func _process(delta):
	if is_grabbed():
		pose()
		
func grab_with_controller(controller, part):
	if controller in _controllers_grabbing:
		return
	_controllers_grabbing.append(controller)
	_controllers_to_parts[controller] = part
	var controller_xform: Transform = controller.global_transform
	_controller_grab_transforms[controller] = controller_xform.xform_inv(global_transform.origin)
	reparent_from_rigidbody()

func release(controller):
	if not controller in _controllers_grabbing:
		return
	if _controllers_to_parts[controller] == _root_grabbable_part:
		_controllers_grabbing.empty()
		_controllers_to_parts.empty()
	else:
		_controllers_grabbing.remove(_controllers_grabbing.find(controller))
		_controllers_to_parts.erase(controller)
	if len(_controllers_grabbing) == 0:
		reparent_to_rigidbody(
			controller.get_parent().get_linear_velocity(),
			controller.get_parent().get_angular_velocity())

func is_grabbed():
	return len(_controllers_grabbing) > 0

func is_part_grabbed(part):
	return part in _controllers_to_parts.values()

func pose():
	pose_root()
	pose_grabbed_parts()

func pose_grabbed_parts():
	if len(_controllers_grabbing) <= 1:
		return
	var second_controller = _controllers_grabbing[1]
	var part = _controllers_to_parts[second_controller]
	var controller_xform: Transform = second_controller.global_transform
	var relative_xform = controller_xform.xform_inv(global_transform.origin)
	part.pose_part(_controller_grab_transforms[second_controller], relative_xform)

func pose_root():
	var first_controller = _controllers_grabbing.front()
	if first_controller != null:
		var grab_transform_or_null = _controllers_to_parts[first_controller].get_grab_transform()
		if grab_transform_or_null == null:
			global_transform = first_controller.global_transform
		else:
			global_transform = grab_transform_or_null.inverse().xform(first_controller.global_transform)

func reparent_to_rigidbody(linear_velocity, angular_velocity):
	var old_transform = global_transform
	global_transform = Transform.IDENTITY
	_placeholder_rigidbody = RigidBody.new()
	var children = get_children()
	for child in children:
		if not child is CollisionObject:
			continue
		for shape_owner_id in child.get_shape_owners():
			var body_shape_owner_id = _placeholder_rigidbody.create_shape_owner(_placeholder_rigidbody)
			var count = child.shape_owner_get_shape_count(shape_owner_id)
			_placeholder_rigidbody.shape_owner_set_transform(
				body_shape_owner_id,
				child.shape_owner_get_transform(shape_owner_id)
			)
			for idx in range(count):
				_placeholder_rigidbody.shape_owner_add_shape(
					body_shape_owner_id,
					child.shape_owner_get_shape(shape_owner_id, idx).duplicate()
				)
	_placeholder_rigidbody.set_global_transform(old_transform)
	_placeholder_rigidbody.set_axis_velocity(linear_velocity)
	_placeholder_rigidbody.angular_velocity = angular_velocity
	var old_parent = get_parent()
	old_parent.remove_child(self)
	old_parent.add_child(_placeholder_rigidbody)
	_placeholder_rigidbody.add_child(self)
	set_owner(_placeholder_rigidbody)

func reparent_from_rigidbody():
	if not _placeholder_rigidbody:
		return
	var new_parent = _placeholder_rigidbody.get_parent()
	_placeholder_rigidbody.remove_child(self)
	_placeholder_rigidbody.free()
	_placeholder_rigidbody = null
	new_parent.remove_child(_placeholder_rigidbody)
	new_parent.add_child(self)
	set_owner(new_parent)
