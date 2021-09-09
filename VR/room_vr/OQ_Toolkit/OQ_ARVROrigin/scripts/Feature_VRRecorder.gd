###
# Feature_VRRecorder
# This is a basic vr interaction recorder that allows to playback vr interactions
# in desktop mode and record interactions on device.
# 
# Note: For Button Preses this requries to disable a Feature_VRSimulator if it is part of the scene
#       because else it will overwrite the button presses on playback
extends Spatial

export var active = true;

export var auto_play_desktop = true;
export var loop_playback = true;
export(String, FILE) var playback_filename = "recording.oqrec";
export var playback_start_frame = 0;
export var playback_end_frame = -1;

export var auto_record_device = false;
export(String, FILE) var rec_filename = "recording";
export var append_number = true;
export var append_date = false;
export var start_rec_via_key = true;

export(vr.BUTTON) var start_first_button = vr.BUTTON.A;
export(vr.BUTTON) var start_second_button = vr.BUTTON.X;

export var rec_head_position = true;
export var rec_head_orientation = true;
export var rec_head_velocity = false;
export var rec_head_acceleration = false;
export var rec_controller_position = true;
export var rec_controller_orientation = true;
export var rec_controller_buttons = true;
export var rec_controller_axis = true;
export var rec_controller_velocity = false;
export var rec_controller_acceleration = false;

var _r = null; # this is the actual recording dictionary (either during recording or during playback)
var _record_active = false; # actively recording
var _playback_active = false; # actively playing back a recording
var _playback_frame = 0;
var _old_in_vr = false;

var _num_recorded_frames = 0;


var _recording_number = 0; # to count if we save multiple recordings from a single session


func _notification(what):
	if (!active): return;
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST || what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if (auto_record_device && vr.inVR): stop_and_save_recording(rec_filename);


func _ready():
	if (!active): return;
	
	if (auto_record_device):
		if (vr.inVR): start_recording();
	
	if (auto_play_desktop && ! _playback_active):
		if (!vr.inVR): load_and_play_recording(playback_filename);
		

var _potential_simulator_node = null;

func stop_playback():
	vr.inVR = _old_in_vr;
	_playback_active = false;
	
	# if there was an active simulator node on playback start we have it remembered in this
	# variable and reset it again to active on animation stop
	if (_potential_simulator_node != null): 
		_potential_simulator_node.active = true;

	
func start_playback():
	_old_in_vr = vr.inVR;
	_playback_frame = playback_start_frame % _r.num_frames;
	_playback_active = true;

	# small check if there is an active VRsimulator as this will overwrite playback vars like buttons
	# only works when it was not renamed... but better than nothing
	# this is probably only needed when vr.inVR is false as else it will be ignored anyway
#	_potential_simulator_node = get_tree().get_root().find_node("Feature_VRSimulator", true, false);
#	if (_potential_simulator_node != null && _potential_simulator_node.active):
#		vr.log_warning("Active Feature_VRSimulator in tree; deactivating it to not interfere with recording playback");
#		_potential_simulator_node.active = false;
#	else:
#		_potential_simulator_node = null; # inactive so no need to remember
		
		
func _process(_dt):
	if (!active): return;
	
	if (start_rec_via_key && !_playback_active):
		if (vr.button_pressed(start_first_button) && vr.button_just_pressed(start_second_button)):
			if (!_record_active):
				start_recording();
			else:
				stop_and_save_recording(rec_filename);
	
	if (_record_active): _record();
	if (_playback_active): _play_back();


# You can give a rec_template from code (an array of strings) on what to record
# else the default configuration set via the exported variables will be used
func start_recording(rec_template = null):
	_record_active = true;
	if (rec_template != null):
		for k in rec_template:
			_r[k] = [];
	else:
		# default recording structure based on node settings
		_r = {}
		if (rec_head_position): 
			_r["head_position"] = [];
		if (rec_head_orientation): 
			_r["head_orientation"] = [];
		if (rec_head_velocity): 
			_r["head_linear_velocity"] = [];
			_r["head_angular_velocity"] = [];
		if (rec_head_acceleration): 
			_r["head_linear_acceleration"] = [];
			_r["head_angular_acceleration"] = [];
		if (rec_controller_position): 
			_r["left_controller_position"] = [];
			_r["right_controller_position"] = [];
		if (rec_controller_orientation): 
			_r["left_controller_orientation"] = [];
			_r["right_controller_orientation"] = [];
		if (rec_controller_buttons): 
			_r["left_controller_buttons"] = [];
			_r["right_controller_buttons"] = [];
		if (rec_controller_axis): 
			_r["left_controller_axis"] = [];
			_r["right_controller_axis"] = [];
		if (rec_controller_velocity): 
			_r["left_controller_linear_velocity"] = [];
			_r["left_controller_angular_velocity"] = [];
			_r["right_controller_linear_velocity"] = [];
			_r["right_controller_angular_velocity"] = [];
		if (rec_controller_acceleration):
			_r["left_controller_linear_acceleration"] = [];
			_r["left_controller_angular_acceleration"] = [];
			_r["right_controller_linear_acceleration"] = [];
			_r["right_controller_angular_acceleration"] = [];
	
	# remember the start time of the recording
	var d = OS.get_datetime();
	_r["start_time"] = 	"%d.%02d.%02d_%02d.%02d.%02d"  % [d.year, d.month, d.day, d.hour, d.minute, d.second];
	_r["target_fps"] = Engine.target_fps;
	_num_recorded_frames = 0;
	
	vr.log_info("Started recording into: " + str(_r));
	vr.show_dbg_info("Feature_VRRecorder", "Recording %d active" % _recording_number);


func _rec_vector3(t : Array, v : Vector3):
	t.append(v.x);
	t.append(v.y);
	t.append(v.z);

func _rec_orientation(t : Array, v : Basis):
	var e = v.get_euler();
	t.append(e.x);
	t.append(e.y);
	t.append(e.z);
	
func _rec_axis(t : Array, controller):
	for i in range(0, 4):
		t.append(controller._sim_get_joystick_axis(i))
	
func _rec_buttons(t : Array, controller):
	var b = controller._buttons_pressed;
	var value = 0;
	for i in range(0, 16):
		value += b[i] << i;
	t.append(value);
	

func _record():
	_num_recorded_frames = _num_recorded_frames + 1;
	# Head
	if (_r.has("head_position")):
		_rec_vector3(_r.head_position, vr.vrCamera.transform.origin);
	if (_r.has("head_orientation")):
		_rec_orientation(_r.head_orientation, vr.vrCamera.transform.basis);
	if (_r.has("head_linear_velocity")):
		_rec_vector3(_r.head_linear_velocity, vr.get_head_linear_velocity());
	if (_r.has("head_linear_acceleration")):
		_rec_vector3(_r.head_linear_acceleration, vr.get_head_linear_acceleration());
	if (_r.has("head_angular_velocity")):
		_rec_vector3(_r.head_angular_velocity, vr.get_head_angular_velocity());
	if (_r.has("head_angular_acceleration")):
		_rec_vector3(_r.head_angular_acceleration, vr.get_head_angular_acceleration());
	
	# Left Controller
	if (_r.has("left_controller_position")):
		_rec_vector3(_r.left_controller_position, vr.leftController.transform.origin);
	if (_r.has("left_controller_orientation")):
		_rec_orientation(_r.left_controller_orientation, vr.leftController.transform.basis);
	if (_r.has("left_controller_buttons")):
		_rec_buttons(_r.left_controller_buttons, vr.leftController);
	if (_r.has("left_controller_axis")):
		_rec_axis(_r.left_controller_axis, vr.leftController);
	if (_r.has("left_controller_linear_velocity")):
		_rec_vector3(_r.left_controller_linear_velocity, vr.get_controller_linear_velocity(vr.leftController.controller_id));
	if (_r.has("left_controller_linear_acceleration")):
		_rec_vector3(_r.left_controller_linear_acceleration, vr.get_controller_linear_acceleration(vr.leftController.controller_id));
	if (_r.has("left_controller_angular_velocity")):
		_rec_vector3(_r.left_controller_angular_velocity, vr.get_controller_angular_velocity(vr.leftController.controller_id));
	if (_r.has("left_controller_angular_acceleration")):
		_rec_vector3(_r.left_controller_angular_acceleration, vr.get_controller_angular_acceleration(vr.leftController.controller_id));
	
	# Right Controller
	if (_r.has("right_controller_position")):
		_rec_vector3(_r.right_controller_position, vr.rightController.transform.origin);
	if (_r.has("right_controller_orientation")):
		_rec_orientation(_r.right_controller_orientation, vr.rightController.transform.basis);
	if (_r.has("right_controller_buttons")):
		_rec_buttons(_r.right_controller_buttons, vr.rightController);
	if (_r.has("right_controller_axis")):
		_rec_axis(_r.right_controller_axis, vr.rightController);
	if (_r.has("right_controller_linear_velocity")):
		_rec_vector3(_r.right_controller_linear_velocity, vr.get_controller_linear_velocity(vr.rightController.controller_id));
	if (_r.has("right_controller_linear_acceleration")):
		_rec_vector3(_r.right_controller_linear_acceleration, vr.get_controller_linear_acceleration(vr.rightController.controller_id));
	if (_r.has("right_controller_angular_velocity")):
		_rec_vector3(_r.right_controller_angular_velocity, vr.get_controller_angular_velocity(vr.rightController.controller_id));
	if (_r.has("right_controller_angular_acceleration")):
		_rec_vector3(_r.right_controller_angular_acceleration, vr.get_controller_angular_acceleration(vr.rightController.controller_id));


func _set_pos(t : Spatial, key):
	if (!_r.has(key)): return;
	var p = _r[key];
	var i = _playback_frame * 3;
	var pos = Vector3(p[i+0],p[i+1],p[i+2]);
	t.transform.origin = pos;

func _set_orientation(t : Spatial, key):
	if (!_r.has(key)): return;
	var o = _r[key];
	var i = _playback_frame * 3;
	var orientation = Basis(Vector3(o[i+0],o[i+1],o[i+2]));
	t.transform.basis = orientation;
	
func _set_buttons(controller, key):
	if (!_r.has(key)): return;
	var buttonArray = _r[key];
	var value = int(buttonArray[_playback_frame]);
	# on playback we set the simulation buttons
	var b2 = controller._simulation_buttons_pressed;
	for i in range(0, 16):
		var v = (value >> i) & 1;
		b2[i] = v;
		
func _set_axis(controller, key):
	if (!_r.has(key)): return;
	var a = _r[key];
	var idx = _playback_frame * 4;
	for i in range(0, 4):
		controller._simulation_joystick_axis[i] = a[i + idx];
	
func _get_vec3_or_0(key):
	if (!_r.has(key)): return Vector3(0,0,0);
	var i = _playback_frame * 3;
	var p = _r[key];
	return Vector3(p[i+0],p[i+1],p[i+2]);
	
	
	

func _play_back():
	if (!_playback_active): return;
	
	vr.inVR = true; 

	
	_set_pos(vr.vrCamera, "head_position");
	_set_orientation(vr.vrCamera, "head_orientation");

	_set_pos(vr.leftController, "left_controller_position");
	_set_orientation(vr.leftController, "left_controller_orientation");
	_set_pos(vr.rightController, "right_controller_position");
	_set_orientation(vr.rightController, "right_controller_orientation");

	_set_buttons(vr.leftController, "left_controller_buttons");
	_set_buttons(vr.rightController, "right_controller_buttons");

	_set_axis(vr.leftController, "left_controller_axis")
	_set_axis(vr.rightController, "right_controller_axis")
	
	vr._sim_linear_velocity[0] = _get_vec3_or_0("head_linear_velocity");
	vr._sim_linear_velocity[1] = _get_vec3_or_0("left_controller_linear_velocity");
	vr._sim_linear_velocity[2] = _get_vec3_or_0("right_controller_linear_velocity");
	vr._sim_linear_acceleration[0] = _get_vec3_or_0("head_linear_acceleration");
	vr._sim_linear_acceleration[1] = _get_vec3_or_0("left_controller_linear_acceleration");
	vr._sim_linear_acceleration[2] = _get_vec3_or_0("right_controller_linear_acceleration");
	vr._sim_angular_velocity[0] = _get_vec3_or_0("head_angular_velocity");
	vr._sim_angular_velocity[1] = _get_vec3_or_0("left_controller_angular_velocity");
	vr._sim_angular_velocity[2] = _get_vec3_or_0("right_controller_angular_velocity");
	vr._sim_angular_acceleration[0] = _get_vec3_or_0("head_angular_acceleration");
	vr._sim_angular_acceleration[1] = _get_vec3_or_0("left_controller_angular_acceleration");
	vr._sim_angular_acceleration[2] = _get_vec3_or_0("right_controller_angular_acceleration");

	
	_playback_frame = (_playback_frame + 1) % _r.num_frames;
	
	if (playback_end_frame > 0 && _playback_frame == playback_end_frame):
		if (!loop_playback): stop_playback();
		else: _playback_frame = playback_start_frame % _r.num_frames
	elif (!loop_playback && _playback_frame == 0): stop_playback();
	
	
	

func stop_and_save_recording(filename = null):
	_record_active = false;
	vr.remove_dbg_info("Feature_VRRecorder");

	if (_r == null):
		vr.log_error("No recording to save.");
		return;
	
	_r["num_frames"] = _num_recorded_frames;
	
	var d = OS.get_datetime();
	if (filename == null || filename == ""):
		filename = "recording_%d.%02d.%02d_%02d.%02d.%02d.oqrec"  % [d.year, d.month, d.day, d.hour, d.minute, d.second];
	else:
		if (append_number):
			filename += "_%03d_" % _recording_number;
			_recording_number += 1;
		if (append_date):
			filename += "_%d.%02d.%02d_%02d.%02d.%02d.oqrec"  % [d.year, d.month, d.day, d.hour, d.minute, d.second]
		#if (!())
		
		if (filename.right(filename.length() - 6) != ".oqrec"):
			filename += ".oqrec";
	
	var save_rec = File.new()
	var err = save_rec.open("user://" + filename, File.WRITE)
	if (err == OK):
		save_rec.store_line(to_json(_r))
		save_rec.close()
		vr.log_info("Saved recording to " + OS.get_user_data_dir() + "/" + filename);
	else:
		vr.log_error("Failed to save recording to "+ OS.get_user_data_dir() + "/" + filename + " ERR=" + str(err));
	
func load_and_play_recording(recording_file_name):
	if (recording_file_name.right(recording_file_name.length() - 6) != ".oqrec"):
		recording_file_name += ".oqrec";
		
	var file = File.new();
	var err = file.open(recording_file_name, file.READ);
	if (err != OK):
		err = file.open("user://" + recording_file_name, file.READ);
	if (err == OK):
		_r = JSON.parse(file.get_as_text()).result;
		_r.num_frames = int(_r.num_frames);
		var num_frames = _r.num_frames;
			
		vr.log_info("Loaded a recording with " + str(num_frames) + " frames");
		for k in _r.keys():
			if _r[k] is Array:
				var check_val = _r[k].size();
				# Do some basic sanity checking of the data here to avoid surprises
				if (check_val != num_frames && check_val != num_frames * 3 && check_val != num_frames * 4):
					vr.log_error("Error in recording: %s has wrong number of elements: %d" % [k, _r[k].size()]);
				
		start_playback();
		file.close();
	else:
		vr.log_error("Failed to load_and_playback_recording " + recording_file_name + ": " + str(err));
