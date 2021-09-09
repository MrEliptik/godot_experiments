# TODO:
# create the hingejoint and kinematic body maybe only when needed
#   and not as part of the scene always
extends Spatial
class_name Feature_RigidBodyGrab

var controller : ARVRController = null;
var grab_area : Area = null;
var held_object = null;
var held_object_data = {};
var grab_mesh : MeshInstance = null;
var held_object_initial_parent : Node


export (vr.GrabTypes) var grab_type := vr.GrabTypes.HINGEJOINT;

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


func grab() -> void:
	if (held_object):
		return

	# find the right rigid body to grab
	var grabbable_rigid_body = null;
	var bodies = grab_area.get_overlapping_bodies();
	if len(bodies) > 0:
		for body in bodies:
			if body is OQClass_GrabbableRigidBody:
				if body.is_grabbable:
					grabbable_rigid_body = body;
	
	if grabbable_rigid_body:
		match grab_type:
			vr.GrabTypes.KINEMATIC:
				start_grab_kinematic(grabbable_rigid_body);
			vr.GrabTypes.VELOCITY:
				start_grab_velocity(grabbable_rigid_body);
			vr.GrabTypes.HINGEJOINT:
				start_grab_hinge_joint(grabbable_rigid_body);

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
	
	match grab_type:
		vr.GrabTypes.KINEMATIC:
			release_grab_kinematic()
		vr.GrabTypes.VELOCITY:
			release_grab_velocity()
		vr.GrabTypes.HINGEJOINT:
			release_grab_hinge_joint()

	if hide_model_on_grab:
		#make model reappear
		var model = $"../Feature_ControllerModel_Left"
		if model:
			model.show()
		else:
			model = $"../Feature_ControllerModel_Right"
			if model:
				model.show()


func start_grab_kinematic(grabbable_rigid_body):
	if grabbable_rigid_body.is_grabbed:
		return
	
	held_object = grabbable_rigid_body
	
	# keep initial transform
	var initial_transform = held_object.get_global_transform()
	
	# reparent
	held_object_initial_parent = held_object.get_parent()
	held_object_initial_parent.remove_child(held_object)
	add_child(held_object)
	
	held_object.global_transform = initial_transform
	held_object.set_mode(RigidBody.MODE_KINEMATIC)
	
	held_object.grab_init(self, grab_type)


func release_grab_kinematic():
	# keep initial transform
	var initial_transform = held_object.get_global_transform()
	
	# reparent
	remove_child(held_object)
	held_object_initial_parent.add_child(held_object)
	
	held_object.global_transform = initial_transform
	held_object.set_mode(RigidBody.MODE_RIGID)
	
	held_object.grab_release()
	
	held_object = null


	
func _release_reparent_mesh():
	if (grab_mesh):
		remove_child(grab_mesh);
		held_object.add_child(grab_mesh);
		grab_mesh.transform = Transform();
		grab_mesh = null;


func _reparent_mesh():
	for c in held_object.get_children():
		if (c is MeshInstance):
			grab_mesh = c;
			break;
	if (grab_mesh):
		vr.log_info("Feature_RigidBodyGrab: reparentin mesh " + grab_mesh.name);
		var mesh_global_trafo = grab_mesh.global_transform;
		held_object.remove_child(grab_mesh);
		add_child(grab_mesh);
		
		if (grab_type == vr.GrabTypes.VELOCITY):
			# now set the mesh transform to be the same as used for the rigid body
			grab_mesh.transform = Transform();
			grab_mesh.transform.basis = held_object.delta_orientation;
		elif (grab_type == vr.GrabTypes.HINGEJOINT):
			grab_mesh.global_transform = mesh_global_trafo;

	
#func start_grab_hinge_joint(grabbable_rigid_body: OQClass_GrabbableRigidBody):
func start_grab_hinge_joint(grabbable_rigid_body):
	if (grabbable_rigid_body == null):
		vr.log_warning("Invalid grabbable_rigid_body in start_grab_hinge_joint()");
		return;
		
	if grabbable_rigid_body.is_grabbed:
		return;
		
	held_object = grabbable_rigid_body
	held_object.grab_init(self, grab_type)
	
	_hinge_joint.set_node_b(held_object.get_path());
	
	if (reparent_mesh): _reparent_mesh();

func release_grab_hinge_joint():
	_release_reparent_mesh();
	_hinge_joint.set_node_b("");
	held_object.grab_release();
	held_object = null;


#func start_grab_velocity(grabbable_rigid_body: OQClass_GrabbableRigidBody):
func start_grab_velocity(grabbable_rigid_body):
	if (grabbable_rigid_body == null):
		vr.log_warning("Invalid grabbable_rigid_body in start_grab_velocity()");
		return;
	
	if grabbable_rigid_body.is_grabbed:
		return;
	
	var temp_global_pos = grabbable_rigid_body.global_transform.origin;
	var temp_rotation = grabbable_rigid_body.global_transform.basis;
	
	
	grabbable_rigid_body.global_transform.origin = temp_global_pos;
	grabbable_rigid_body.global_transform.basis = temp_rotation;
	
	held_object = grabbable_rigid_body;
	held_object.grab_init(self, grab_type);

	if (reparent_mesh): _reparent_mesh();


func release_grab_velocity():
	_release_reparent_mesh();
	
	held_object.grab_release()
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
