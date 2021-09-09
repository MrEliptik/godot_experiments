extends Spatial

export var active = true;

var grab_left = null;
var grab_right = null;

var active_grab = null;
var last_grab = null;

var start_position = Vector3();

func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error(" in Feature_Climbing: parent not ARVROrigin.");

	grab_left = vr.leftController.find_node("Feature_StaticGrab");
	grab_right = vr.rightController.find_node("Feature_StaticGrab");
	
	if (grab_left == null || grab_right == null):
		vr.log_error(" in Feature_Climbing; both controllers need the Feature_StaticGrab");

func start_grab():
	start_position = vr.vrOrigin.global_transform.origin;
	vr.log_info(str("Start Grab at ", active_grab.grab_position));


func _physics_process(_dt):
	if (!active): return;

	if (grab_left.is_just_grabbing):
		#last_grab = active_grab;
		active_grab = grab_left;
		start_grab();
	
	if (grab_right.is_just_grabbing):
		#last_grab = active_grab;
		active_grab = grab_right;
		start_grab();
		
	if (last_grab != null && active_grab != null && !active_grab.is_grabbing):
		active_grab = last_grab;
		last_grab = null;
		start_grab();
	elif (active_grab != null && !active_grab.is_grabbing): # letting loose
		active_grab = null;
	
	if (active_grab):
		vr.vrOrigin.is_fixed = true;
		vr.vrOrigin.global_transform.origin = start_position - active_grab.delta_position;
	else:
		vr.vrOrigin.is_fixed = false;
		
