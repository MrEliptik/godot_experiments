extends Spatial

onready var skeleton_IK = $Armature/Skeleton/SkeletonIK
onready var grab_area = $Armature/Skeleton/BoneAttachment2/Area
onready var grab_point = $Armature/Skeleton/BoneAttachment2/GrabPoint
onready var ik_target = $Target

var target_grabbed = false
var cv_camera
var rest_position
var drop_position

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton_IK.start(true)
	
func set_positions(rest_pos, drop_pos):
	rest_position = rest_pos
	drop_position = drop_pos
	
func set_cv_camera(camera):
	cv_camera = camera

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move_arm(target_point):
	if target_point:
		# We arrived to the target_point
		if !skeleton_IK.is_running():
			grab()
		# We grabbed tha target, go to drop position
		if target_grabbed:
			ik_target.global_transform.origin = drop_position.global_transform.origin
			skeleton_IK.start(true)
			if !skeleton_IK.is_running():
				grab_point.get_child(0).let_go()
				grab_area.monitoring = false
				target_grabbed = false
				target_point = null
		# We go to the target_point position
		else:
			ik_target.global_transform.origin = cv_camera.project_position(target_point, 1.0)
			skeleton_IK.start(true)
	# No target_point, we go to rest position
	else:
		ik_target.global_transform.origin = rest_position.global_transform.origin
		skeleton_IK.start(true)
		
func grab():
	grab_area.monitoring = true
	var bodies = grab_area.get_overlapping_bodies()
	if bodies.empty(): return
	for body in bodies:
		if body.has_method("pick_up"):
			body.pick_up(grab_point)
			target_grabbed = true
			grab_area.monitoring = false
