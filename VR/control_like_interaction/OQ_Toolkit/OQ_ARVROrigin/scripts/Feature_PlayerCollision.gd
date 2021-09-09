extends KinematicBody

export var enabled := true;
export var debug_information := false;
export var capsule_radius := 0.15;

export var step_offset := 0.0;

onready var collision_object = $CollisionShape;

func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error("Feature_StickMovement: parent is not ARVROrigin");
		
	_update_collsion_shape_start_position();


func _show_debug_information():
	var slide_count = get_slide_count();
	var on_floor = 1 if is_on_floor() else 0;
	var on_wall = 1 if is_on_wall() else 0;
	
	
	var colliders = "";
	for c in range(0, slide_count):
		colliders += get_slide_collision(c).collider.name + ",";
	
	
	vr.show_dbg_info("Feature_PlayerCollision", "Slide Count: %d; on floor: %d; on wall: %d; last update: %d;\n         Colliders: %s" % [slide_count, on_floor, on_wall, vr.frame_counter, colliders]);


func _update_collsion_shape_start_position():
	var player_height = vr.get_current_player_height();
	collision_object.shape.radius = capsule_radius;
	collision_object.shape.height = player_height - 2.0 * capsule_radius - step_offset;
	global_transform.origin = vr.vrCamera.global_transform.origin;
	global_transform.origin.y -= (player_height-step_offset) * 0.5;
	
	

func oq_locomotion_stick_check_move(velocity, dt):
	if (!enabled): return velocity;

	_update_collsion_shape_start_position();

	velocity = move_and_slide(velocity, Vector3(0.0, 1.0, 0.0));
	
	if (debug_information):
		_show_debug_information();
	
	return velocity;
