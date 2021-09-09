extends ARVRCamera

export var debug_information := false;


# Sets up everything as it is expected by the helper scripts in the vr singleton
func _enter_tree():
	if (!vr):
		vr.log_error(" in OQ_Camera._enter_tree(): no vr singleton");
		return;
	if (vr.vrCamera):
		vr.log_warning(" in OQ_Camera._enter_tree(): vrCamera already set; overwrting it");
	vr.vrCamera = self;

func _exit_tree():
	if (!vr):
		vr.log_error(" in OQ_Camera._exit_tree(): no vr singleton");
		return;
	if (vr.vrCamera != self):
		vr.log_error(" in OQ_Camera._exit_tree(): different vrCamera");
		return;
	vr.vrCamera = null;
	
func _show_debug_information():
	var vro = global_transform.origin;
	vr.show_dbg_info(name, "world_pos=(%.2f, %.2f, %.2f)" %
	[vro.x, vro.y, vro.z]);


func get_angular_velocity():
	return vr.get_head_angular_velocity();
func get_angular_acceleration():
	return vr.get_head_angular_acceleration();
func get_linear_velocity():
	return vr.get_head_linear_velocity();
func get_linear_acceleration():
	return vr.get_head_linear_acceleration();

func _process(_dt):
	if (debug_information): _show_debug_information();
