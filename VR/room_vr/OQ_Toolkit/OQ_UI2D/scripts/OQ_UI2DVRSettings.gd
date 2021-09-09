extends Spatial


var foveation_level_option_button : OptionButton = null;
var extra_latency_option_button : OptionButton = null;
var tracking_space_option_button : OptionButton = null;
var boundary_visible_check_button : CheckButton = null;
var ipd_info_label : Label = null;
var device_type_line_edit : LineEdit = null;
var controller_model_override_option_button : OptionButton = null;


func _setup_ui_elements():
	var r = $OQ_UI2DCanvas;
	foveation_level_option_button = r.find_node("FoveationLevel_OptionButton", true, false);
	
	foveation_level_option_button.add_item("Off");
	foveation_level_option_button.add_item("Low");
	foveation_level_option_button.add_item("Medium");
	foveation_level_option_button.add_item("High");
	foveation_level_option_button.add_item("HighTop");
	foveation_level_option_button.select(vr.oculus_mobile_settings_cache["foveation_level"]);
	
	extra_latency_option_button = r.find_node("ExtraLatency_OptionButton", true, false);
	extra_latency_option_button.add_item("Off");
	extra_latency_option_button.add_item("On");
	extra_latency_option_button.add_item("Dynamic");
	extra_latency_option_button.select(vr.oculus_mobile_settings_cache["extra_latency_mode"]);
	
	tracking_space_option_button = r.find_node("TrackingSpace_OptionButton", true, false);
	tracking_space_option_button.add_item("LOCAL", vr.ovrVrApiTypes.OvrTrackingSpace.VRAPI_TRACKING_SPACE_LOCAL);
	tracking_space_option_button.add_item("LOCAL_FLOOR", vr.ovrVrApiTypes.OvrTrackingSpace.VRAPI_TRACKING_SPACE_LOCAL_FLOOR);
	tracking_space_option_button.add_item("LOCAL_TILTED", vr.ovrVrApiTypes.OvrTrackingSpace.VRAPI_TRACKING_SPACE_LOCAL_TILTED);
	tracking_space_option_button.add_item("STAGE", vr.ovrVrApiTypes.OvrTrackingSpace.VRAPI_TRACKING_SPACE_STAGE);
	tracking_space_option_button.add_item("LOCAL_FIXED_YAW", vr.ovrVrApiTypes.OvrTrackingSpace.VRAPI_TRACKING_SPACE_LOCAL_FIXED_YAW);
	tracking_space_option_button.select(vr.oculus_mobile_settings_cache["tracking_space"]);
	
	boundary_visible_check_button = r.find_node("BoundaryVisible_CheckButton", true, false);
	boundary_visible_check_button.pressed = vr.oculus_mobile_settings_cache["boundary_visible"]
	
	ipd_info_label = r.find_node("IPDInfo_Label", true, false);
	
	device_type_line_edit = r.find_node("DeviceType_LineEdit", true, false);
	
	controller_model_override_option_button = r.find_node("ControllerOverride_OptionButton", true, false);
	controller_model_override_option_button.add_item("Auto");
	controller_model_override_option_button.add_item("Quest 1");
	controller_model_override_option_button.add_item("Quest 2");
	
func _ready():
	_setup_ui_elements();


func _process(_dt):
	var device_type_str = "Unknown";
	
	if (is_visible_in_tree() && vr.ovrUtilities):
		ipd_info_label.set_text("Current IPD: %.1fmm" % (vr.get_ipd() * 1000.0));
		
		if (vr.is_oculus_quest_1_device()):
			device_type_str = "Quest 1";
		elif (vr.is_oculus_quest_2_device()):
			# Note: the the Oculus API only returns Quest 2 device type if you
			# set the com.oculus.supportedDevices metadata to "quest|quest2"
			# in the AndroidManifest.xml
			device_type_str = "Quest 2";
	
	device_type_line_edit.text = device_type_str;


func _on_FoveationLevel_OptionButton_item_selected(id):
	vr.set_foveation_level(id);


func _on_ExtraLatency_OptionButton_item_selected(id):
	vr.set_extra_latency_mode(id);


func _on_TrackingSpace_OptionButton_item_selected(id):
	vr.set_tracking_space(id);


func _on_BoundaryVisible_CheckButton_toggled(button_pressed):
	vr.request_boundary_visible(button_pressed);


func _on_ControllerOverride_OptionButton_item_selected(id):
	var new_type = OQ_ARVRController.TOUCH_CONTROLLER_MODEL_TYPE.AUTO
	if (id == 1):
		new_type = OQ_ARVRController.TOUCH_CONTROLLER_MODEL_TYPE.QUEST1;
	elif (id == 2):
		new_type = OQ_ARVRController.TOUCH_CONTROLLER_MODEL_TYPE.QUEST2;
			
	if (vr.leftController):
		vr.leftController.controller_model_type = new_type
	if (vr.rightController):
		vr.rightController.controller_model_type = new_type
