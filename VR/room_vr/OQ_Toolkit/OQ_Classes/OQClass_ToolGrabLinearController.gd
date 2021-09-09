extends OQClass_ToolGrabController

class_name OQClass_ToolGrabLinearController

# The axis along which this part slides, in the OQClass_Tool's coordinate space.
export(Vector3) var slide_axis = Vector3(1, 0, 0)

# The lower limit of the sliding motion.
export(float) var lower_limit = 0

# The upper limit of the sliding motion.
export(float) var upper_limit = 0.05

# How far beyond the object's range of motion a controller can get before it slips off.
export(float) var slip_threshold = 0.05

# Whether or not this part should snap back to its rest position when released.
export(bool) var should_snap_back = true

# The rest position of this part, along the slide axis
export(float) var rest_position = 0

var _distance = 0.0
var _slide_extension = 0.0
var _original_part_posiiton = null

func _ready():
	_original_part_posiiton = get_parent().transform.origin

func pose_part(start_grab_pos: Vector3, new_grab_pos: Vector3):
	# Determine how the extension of this sliding part.
	var projected_start_pos = start_grab_pos.project(slide_axis)
	var projected_end_pos = new_grab_pos.project(slide_axis)
	var desired_extension = projected_start_pos.distance_to(projected_end_pos)
	var actual_extension = clamp(desired_extension, lower_limit, upper_limit)
	# Determine whether or not a player's hand has slipped
	var slide_start_pos = start_grab_pos.slide(slide_axis)
	var slide_end_pos = new_grab_pos.slide(slide_axis)
	if slide_start_pos.distance_to(slide_end_pos) > slip_threshold or abs(desired_extension - actual_extension) > slip_threshold:
		.hand_slipped()
		return
	# Actually pose the part.
	var new_pos = slide_axis.normalized() * actual_extension
	get_parent().transform.origin = _original_part_posiiton + new_pos

func process_release(part: Spatial):
	if not should_snap_back:
		return
	var new_pos = slide_axis.normalized() * rest_position
	get_parent().transform.origin = _original_part_posiiton + new_pos
