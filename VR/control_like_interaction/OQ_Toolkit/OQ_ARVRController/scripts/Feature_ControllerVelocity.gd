# Note: this is not needed on oculus quest as there we can query
# the controller velocity directly from the API which is exposed via
# vr.get_controller_linear_velocity(controller_id)
extends Spatial

var controller_velocity = Vector3(0, 0, 0)

var prior_controller_position = Vector3(0, 0, 0)
var prior_controller_velocities = []

var controller : ARVRController = null;

func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_RigidBodyGrab: parent not ARVRController.");
		
func update_controller_velocity(dt):
	controller_velocity = Vector3(0, 0, 0)
	
	if prior_controller_velocities.size() > 0:
		for vel in prior_controller_velocities:
			controller_velocity += vel

		# Get the average velocity, instead of just adding them together.
		controller_velocity = controller_velocity / prior_controller_velocities.size()

	prior_controller_velocities.append((global_transform.origin - prior_controller_position) / dt)
	
	controller_velocity += (global_transform.origin - prior_controller_position) / dt
	prior_controller_position = global_transform.origin

	if prior_controller_velocities.size() > 30:
		prior_controller_velocities.remove(0)

func _process(dt):
	update_controller_velocity(dt);
