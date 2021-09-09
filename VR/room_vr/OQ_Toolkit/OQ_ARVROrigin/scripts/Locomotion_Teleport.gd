# This implementation of Locomotion_Teleport comes with some basic visualization
# This is still a very early implementation; there are still a lot of open points to implement:
# TODO:
#  - add possibility to pre-rotate the target location (via stick)
#  - add target space check via a collision shape (or callback)
#  - add export variables to configure the target_marker from the outside
#  - add export feature to configure the arc_mesh visualization from the outside
#  - blink-teleport mode

extends Spatial

export var active = true;
export var debug_information := false;

export var valid_angle_cos := 0.9;
export var valid_color := Color(0.5,1.0,0.5, 1.0);
export var invalid_color := Color(1.0, 0.5, 0.5, 1.0);

export var distance_mult := 1.5;
export var num_steps := 20;

export (int, FLAGS) var collision_mask = 1 setget set_collision_mask, get_collision_mask;


export(vr.BUTTON) var show_teleport_button = vr.BUTTON.RIGHT_TOUCH_INDEX_TRIGGER;
export(vr.BUTTON) var perform_teleport_button = vr.BUTTON.RIGHT_INDEX_TRIGGER;

var controller : ARVRController = null;

var teleport_valid := false;
var teleport_normal := Vector3(0.0, 1.0, 0.0);
var teleport_position := Vector3(0.0, 0.0, 0.0);

onready var arc_mesh = $arc_mesh;
onready var arc_material = $arc_mesh.get_surface_material(0);

onready var arc_ray = $arc_raycast;

func _show_debug_information():
	vr.show_dbg_info("teleport_position", teleport_position);
	vr.show_dbg_info("teleport_normal", teleport_normal);
	
func set_collision_mask(_mask):
	collision_mask = _mask
	arc_ray.collision_mask = collision_mask

func get_collision_mask():
	return collision_mask

func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error("Locomotion_Teleport: parent is not ARVROrigin");
		
	controller = vr.rightController;
	
	_update_arc();

func _update_arc():
	teleport_valid = false;
	
	#hack to avoid culling of the mesh by moving it in front of the camera
	#(necessary since the actual mesh posiiton is computed in the fragment shader)
	global_transform.origin = vr.vrCamera.global_transform.origin - vr.vrCamera.global_transform.basis.z; #needed so the mesh is not culled
	
	var direction = controller.get_grab_transform().basis.y * distance_mult;
	var start_position = controller.global_transform.origin + direction * 0.125;

	
	var step_distance = 0.125;
	
	var p0 = start_position;
	var t = 0.0;
	
	arc_ray.global_transform.basis = Basis(); # reset orientation as we do all calculations in world space
	
	# now we cast several ray segments to figure out where the arc hits
	for i in range(num_steps):
		t = (i+1)*step_distance;
		var p1 = start_position + t * direction - t*t*Vector3(0,1,0);

		arc_ray.global_transform.origin = p0;
		arc_ray.cast_to = p1 - p0;
		arc_ray.force_raycast_update();

		p0 = p1;

		if (arc_ray.is_colliding()):
			teleport_normal = arc_ray.get_collision_normal();
			teleport_position = arc_ray.get_collision_point();
			if (arc_ray.get_collision_normal().dot(Vector3(0,1,0))>=valid_angle_cos):
				teleport_valid = true;
			
			# here we perform a binary search for the collision point; maybe it would be better to directly solve the quadratic equation...
#			t = i * step_distance;
#			for r in range(4): # number of refinement steps
#				step_distance *= 0.5;
#				t += step_distance;
#				p1 = start_position + t * direction - t*t*Vector3(0,1,0);
#				arc_ray.cast_to = p1 - p0;
#				arc_ray.force_raycast_update();
#				if (arc_ray.is_colliding()):
#					t -= step_distance;
			break;
	
	
	var arc_length = t;
	arc_material.set_shader_param("start_position", start_position);
	arc_material.set_shader_param("direction", direction);
	arc_material.set_shader_param("arc_length", arc_length);
	if (teleport_valid):
		arc_material.set_shader_param("color", valid_color);
		direction.y = 0.0;
		$target_marker.look_at_from_position(teleport_position, teleport_position + direction, Vector3(0,1,0));
		$target_marker.visible = true;
	else:
		arc_material.set_shader_param("color", invalid_color);
		$target_marker.visible = false;


func _physics_process(dt):
	if (!active): return;
	
	if (teleport_valid && vr.button_just_pressed(perform_teleport_button)):
		var foot_position = vr.vrCamera.global_transform.origin;
		foot_position.y -= vr.get_current_player_height();
		var delta_position = teleport_position - foot_position;
		
		vr.vrOrigin.global_transform.origin += delta_position;


func _process(dt):
	if (!active): return;
	
	_update_arc();

	if (debug_information): _show_debug_information();

