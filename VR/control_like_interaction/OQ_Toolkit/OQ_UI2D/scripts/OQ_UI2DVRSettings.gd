extends Spatial


var foveation_level_option_button : OptionButton = null;
var extra_latency_option_button : OptionButton = null;
var tracking_space_option_button : OptionButton = null;
var boundary_visible_check_button : CheckButton = null;
var ipd_info_label : Label = null;


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
	
func _ready():
	_setup_ui_elements();


func _process(_dt):
	if (is_visible_in_tree() && vr.ovrUtilities):
		ipd_info_label.set_text("Current IPD: %.1fmm" % (vr.get_ipd() * 1000.0));


func _on_FoveationLevel_OptionButton_item_selected(id):
	vr.set_foveation_level(id);


func _on_ExtraLatency_OptionButton_item_selected(id):
	vr.set_extra_latency_mode(id);


func _on_TrackingSpace_OptionButton_item_selected(id):
	vr.set_tracking_space(id);


func _on_BoundaryVisible_CheckButton_toggled(button_pressed):
	vr.request_boundary_visible(button_pressed);
