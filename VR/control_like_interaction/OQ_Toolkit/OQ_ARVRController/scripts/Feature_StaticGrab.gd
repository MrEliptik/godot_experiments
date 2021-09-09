extends Spatial

var grab_area : Area = null;
var controller : ARVRController = null;

# if true the body is checked if it has a method "oq_can_static_grab" and calls it
# to check if it actually can be grabbed. All other objects are ignored
export var check_parent_can_static_grab = false;

signal oq_static_grab_started;
signal oq_static_grab_ended;

var is_grabbing = false;
var is_just_grabbing = false;
var grabbed_object = null;
var grab_position = Vector3();
var delta_position = Vector3();

var _additional_grab_checker = null;

export(vr.CONTROLLER_BUTTON) var grab_button = vr.CONTROLLER_BUTTON.GRIP_TRIGGER;

func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_StaticGrab: parent not ARVRController.");
	grab_area = $GrabArea;
	
	
func _physics_process(_dt):
	grab_area.global_transform = controller.get_palm_transform();
	if (controller._button_just_pressed(grab_button)):

		if (_additional_grab_checker):
			grabbed_object = _additional_grab_checker.oq_additional_static_grab_check(grab_area, controller);

		var overlapping_bodies = grab_area.get_overlapping_bodies();
		for b in overlapping_bodies:
			if (check_parent_can_static_grab):
				var p = b.get_parent();
				if (p && p.has_method("oq_can_static_grab")):
					if (!p.oq_can_static_grab(b, grab_area, controller, overlapping_bodies)): continue;
				else:
					continue;
			
			grabbed_object = b;
			break;

		if (grabbed_object):
			is_grabbing = true;
			is_just_grabbing = true;
			grab_position = controller.translation; # we need the local translation here as we will move the origin
			emit_signal("oq_static_grab_started", grabbed_object, controller)

	else:
		is_just_grabbing = false;
	
	if (!controller._button_pressed(grab_button)):
		if (is_grabbing):
			emit_signal("oq_static_grab_ended", grabbed_object, controller)
			grabbed_object = null;
			is_grabbing = false;
	elif (is_grabbing):
		delta_position = vr.vrOrigin.global_transform.basis.xform(controller.translation - grab_position);


