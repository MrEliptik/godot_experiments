# TODO:
# create the hingejoint and kinematic body maybe only when needed
#   and not as part of the scene always
extends Spatial
class_name Feature_ToolGrab

var controller : ARVRController = null;
var grab_area : Area = null;
var held_object = null;
var held_object_data = {};
var grab_mesh : MeshInstance = null;
var held_object_initial_parent : Node

export var collision_body_active := false;

onready var _hinge_joint : HingeJoint = $HingeJoint;

export var reparent_mesh = false;

export var hide_model_on_grab := false;

func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_RigidBodyGrab: parent not ARVRController.");
	grab_area = $GrabArea;
	
	
	if (!collision_body_active):
		$CollisionKinematicBody/CollisionBodyShape.disabled = true;
	
	
	# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
	#controller.connect("button_pressed", self, "_on_ARVRController_button_pressed")
	#controller.connect("button_release", self, "_on_ARVRController_button_release")


func _physics_process(_dt):
	# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
	update_grab()


# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
func update_grab() -> void:
	if (controller._button_just_pressed(vr.CONTROLLER_BUTTON.GRIP_TRIGGER)):
		grab()
	elif (!controller._button_pressed(vr.CONTROLLER_BUTTON.GRIP_TRIGGER)):
		release()
	elif (held_object != null and held_object.did_hand_slip()):
		release()


func grab() -> void:
	if (held_object):
		vr.log_warning("Can't grab, already grabbing something")
		return

	# find the right tool to grab
	var grabbable_tool = null;
	var bodies = grab_area.get_overlapping_areas();
	if len(bodies) > 0:
		for body in bodies:
			if body is OQClass_GrabbableToolPart and not body.is_grabbed():
				grabbable_tool = body;
	
	if grabbable_tool:
		start_grab_tool(grabbable_tool);

		if hide_model_on_grab:
			#make model dissappear
			var model = $"../Feature_ControllerModel_Left"
			if model:
				model.hide()
			else:
				model = $"../Feature_ControllerModel_Right"
				if model:
					model.hide()


func release():
	if !held_object:
		return

	release_grab_tool()

	if hide_model_on_grab:
		#make model reappear
		var model = $"../Feature_ControllerModel_Left"
		if model:
			model.show()
		else:
			model = $"../Feature_ControllerModel_Right"
			if model:
				model.show()


#func start_grab_tool(grabbable_tool: OQClass_GrabbableTool):
func start_grab_tool(grabbable_tool):
	if (grabbable_tool == null):
		vr.log_warning("Invalid grabbable_tool in start_grab_tool()");
		return;

	if (grabbable_tool.parent_tool == null):
		vr.log_warning("Grabbed object was not a tool part")
		return;
	
	held_object = grabbable_tool;
	held_object.grab_init(self);

func release_grab_tool():
	held_object.grab_release(self)
	held_object = null

# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
#func _on_ARVRController_button_pressed(button_number):
#	if button_number != vr.CONTROLLER_BUTTON.GRIP_TRIGGER:
#		return
#
#	# if grab button, grab
#	grab()
#
#func _on_ARVRController_button_release(button_number):
#	if button_number != vr.CONTROLLER_BUTTON.GRIP_TRIGGER:
#		return
#
#	# if grab button, grab
#	release()
