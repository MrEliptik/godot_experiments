extends Spatial

enum CollisionType {
	AUTOMATIC,
	FIXED_GROUND,
	RAYCAST,
	#PLAYERCOLLISION,
	#CAPSULE, # not yet implemented...
}


export var active := true;
export var debug_information := false;

export var ground_height := 0.0;
export var gravity := 9.81;
export var epsilon := 0.001;

export var height_offset := 0.0; # you can make the player taller with this


export var force_move_up : bool = false;
export var move_up_speed : float = 0.0; # 0.0 == instance move up
export var max_raycast_distance : float = 128.0; 
export var ray_collision_mask : int = 2147483647;
export var fall_without_hit : bool = false;
export var fall_raycast_radius = 0.0;

export(CollisionType) var collision_type = CollisionType.AUTOMATIC;

var move_checker = null;

var feature_player_collision : KinematicBody = null;


var on_ground = true;

func _show_debug_information():
	var mcn = move_checker.name if (move_checker) else "null";
	vr.show_dbg_info("Feature_Falling", "on_ground = %s; move_checker = %s; collision_type = %s" 
	% [str(on_ground), mcn, str(collision_type)]);

func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error("Feature_Falling: parent is not ARVROrigin");
		
	if (collision_type == CollisionType.AUTOMATIC):
		var pc = get_parent().find_node("Feature_PlayerCollision", false, false);
		if (pc is KinematicBody):
			feature_player_collision = pc;
			
			collision_type = CollisionType.RAYCAST;
			if (fall_raycast_radius == 0.0): fall_raycast_radius = feature_player_collision.capsule_radius;
			vr.log_info("Feature_Falling: automatic: using raycast with radius %.2f for falling" % [fall_raycast_radius]);
			
			#collision_type = CollisionType.PLAYERCOLLISION;
			#vr.log_info("Feature_Falling: automatic: using Feature_PlayerCollision for falling");
		else:
			vr.log_info("Feature_Falling: automatic: using raycast for falling");
			collision_type = CollisionType.RAYCAST;
		

func _get_raycast_hit_center(space_state, from, to):
	return space_state.intersect_ray(from, to, [], ray_collision_mask);
	
func _get_raycast_hit_surrounding(h0, space_state, from, to):
	if (fall_raycast_radius > 0.0):
		# simple 4 ray in world space offseted
		var o1 = Vector3(fall_raycast_radius, 0, 0);
		var o2 = Vector3(-fall_raycast_radius, 0, 0);
		var o3 = Vector3(0, 0, fall_raycast_radius);
		var o4 = Vector3(0, 0, -fall_raycast_radius);

		#var h0 = space_state.intersect_ray(from, to, [], ray_collision_mask);
		var h1 = space_state.intersect_ray(from+o1, to+o1, [], ray_collision_mask);
		var h2 = space_state.intersect_ray(from+o2, to+o2, [], ray_collision_mask);
		var h3 = space_state.intersect_ray(from+o3, to+o3, [], ray_collision_mask);
		var h4 = space_state.intersect_ray(from+o4, to+o4, [], ray_collision_mask);
		
		if (!h0 || !h1 || !h2 || !h3 || !h4): return false;
		
		if (abs(h0.position.y - h1.position.y) > fall_raycast_radius): return false
		if (abs(h0.position.y - h2.position.y) > fall_raycast_radius): return false;
		if (abs(h0.position.y - h3.position.y) > fall_raycast_radius): return false;
		if (abs(h0.position.y - h4.position.y) > fall_raycast_radius): return false;
	
		return true;
	else:
		return _get_raycast_hit_center(space_state, from, to);




var fall_speed = 0.0;

func _physics_process(dt):
	if (!active): 
		fall_speed = 0.0;
		return;
	
	if (vr.vrOrigin.is_fixed): 
		fall_speed = 0.0; # reset the fall speed when the player is fixed
		return;
	
	on_ground = true;
	
	var head_position = vr.vrCamera.global_transform.origin;
	var player_height = vr.get_current_player_height() + height_offset;
	var foot_height = head_position.y - player_height;
	
	var max_fall_distance = 0.0;

	
	if (collision_type == CollisionType.FIXED_GROUND):
		if (foot_height > ground_height + epsilon):
			on_ground = false;
			#print("head_position: ", head_position);
			#print("foot_height: ", foot_height);
			#print("ground_height: ", ground_height);
			max_fall_distance = foot_height - ground_height;
		else:
			on_ground = true;
#	elif (collision_type == CollisionType.PLAYERCOLLISION):
#		feature_player_collision._update_collsion_shape_start_position();
#		var delta_move = Vector3(0, -gravity, 0);
#		delta_move = feature_player_collision.move_and_slide(delta_move, Vector3(0,1,0));
#		on_ground = feature_player_collision.is_on_floor();
#		max_fall_distance = -delta_move.y;
		
	elif (collision_type == CollisionType.RAYCAST):
		var space_state = get_world().direct_space_state
		var from = head_position;
		var to = from - Vector3(0.0, max_raycast_distance, 0.0);
		var hit_result = _get_raycast_hit_center(space_state, from, to);
		
		
		if (fall_without_hit):
			on_ground = false;
			max_fall_distance = max_raycast_distance;
		else:
			on_ground = false;
			max_fall_distance = 0.0;
		
		if (hit_result):
			var hit_point = hit_result.position;
			var hit_dist = head_position.y - hit_point.y;
			
			#vr.show_dbg_info("rayCastInfo", "player_height = %f foot_height = %f hit_dist = %f" % [player_height, foot_height, hit_dist]);

			if (hit_dist > player_height + epsilon):
				on_ground = false;
				max_fall_distance = hit_dist - player_height;
				#vr.show_dbg_info("dbgFalling", "fallingHit: dist = %f; player_height = %f" % [hit_dist, player_height]);
			else:
				#vr.show_dbg_info("dbgFalling", "onGround: dist = %f; player_height = %f" % [hit_dist, player_height]);
				on_ground = true;
				#var surrounding_can_fall = true;
				max_fall_distance = 0.0;
				
				#if (fall_raycast_radius > 0.0):
				#	surrounding_can_fall = _get_raycast_hit_surrounding(hit_result, space_state, from, to);
			
				# move only up when enabled and if we have a similar surrounding (this avoids moving up too soon when leaning)
				if (force_move_up && (hit_dist < player_height - epsilon)):
					var move = Vector3(0,0,0);
					if (move_up_speed == 0.0):
						move.y = (player_height - hit_dist);
					else:
						move.y += min(move_up_speed* dt, player_height - hit_dist);
					
					if (move_checker):
						move = move_checker.oq_feature_falling_check_move_up(move);
					
					vr.vrOrigin.translation += move;
					
		else:
			#vr.show_dbg_info("dbgFalling", "fallingNoHit: player_height = %f" % [player_height]);
			pass;

	if (!on_ground):
		fall_speed += gravity * dt;
		vr.vrOrigin.translation.y -= min(max_fall_distance, fall_speed * dt);
	else:
		fall_speed = 0.0;
		
	if (debug_information):
		_show_debug_information();

