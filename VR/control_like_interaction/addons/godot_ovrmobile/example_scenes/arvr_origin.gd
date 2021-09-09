extends ARVROrigin
# This is an example implementaiton on how to initialize the Oculus Mobile Plugin (godot_ovrmobile)
# It can be used as a drop-in solution for quick testing or modified to your needs
# It shows some of the common things needed to interact with the Godot Oculus Mobile Plugin
#
# To view log/print messages use `adb logcat -s godot:* GodotOVRMobile:*` from a command prompt


# these will be initialized in the _ready() function; but they will be only available
# on device
# the init config is needed for setting parameters that are needed before the VR system starts up
var ovr_init_config = null;

# the other APIs are available during runtime
var ovr_performance = null;
var ovr_display = null;
var ovr_vr_api_proxy = null;
var ovr_system = null;

# some of the Oculus VrAPI constants are defined in this file. Have a look into it to learn more
var ovrVrApiTypes = load("res://addons/godot_ovrmobile/OvrVrApiTypes.gd").new()

# many settings should only be applied once when running; this variable
# gets reset on application start or when it wakes up from sleep
var _performed_runtime_config = false

func _ready():
	_initialize_ovr_mobile_arvr_interface()


func _process(delta_t):
	_check_and_perform_runtime_config()


# this code check for the OVRMobile inteface; and if successful also initializes the
# .gdns APIs used to communicate with the VR device
func _initialize_ovr_mobile_arvr_interface():
	# Find the OVRMobile interface and initialise it if available
	var arvr_interface = ARVRServer.find_interface("OVRMobile")
	if !arvr_interface:
		print("Couldn't find OVRMobile interface")
	else:
		# the init config needs to be done before arvr_interface.initialize()
		ovr_init_config = load("res://addons/godot_ovrmobile/OvrInitConfig.gdns");
		if (ovr_init_config):
			ovr_init_config = ovr_init_config.new()
			ovr_init_config.set_render_target_size_multiplier(1) # setting to 1 here is the default

		# Configure the interface init parameters.
		if arvr_interface.initialize():
			# load the .gdns classes.
			ovr_display = load("res://addons/godot_ovrmobile/OvrDisplay.gdns");
			ovr_performance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns");
			ovr_vr_api_proxy = load("res://addons/godot_ovrmobile/OvrVrApiProxy.gdns");
			ovr_system = load("res://addons/godot_ovrmobile/OvrSystem.gdns")

			# And now instance the .gdns classes for use if load was successfull
			
			# Update the refresh rate based on the device type. The value could
			# also be picked from the values returned by 
			# ovr_display.get_supported_display_refresh_rates()
			var refresh_rate = 72 # Default common value for Quest devices
			if (ovr_system):
				ovr_system = ovr_system.new()
				if (ovr_system.is_oculus_quest_2_device()):
					refresh_rate = 90 # Only supported on Quest 2 devices
			
			if (ovr_display): 
				ovr_display = ovr_display.new()
				# Get the list of supported display refresh rates.
				print("Display refresh rates: " + str(ovr_display.get_supported_display_refresh_rates()))
				# Get the device color space
				print("Device color space: " + str(ovr_display.get_color_space()))
				# Update the refresh rate
				ovr_display.set_display_refresh_rate(refresh_rate)
				
			if (ovr_performance): 
				ovr_performance = ovr_performance.new()
			if (ovr_vr_api_proxy): 
				ovr_vr_api_proxy = ovr_vr_api_proxy.new()

			get_viewport().arvr = true
			Engine.iterations_per_second = refresh_rate
			
			# Connect to the plugin signals
			_connect_to_signals()

			print("Loaded OVRMobile")
		else:
			print("Failed to enable OVRMobile")


func _connect_to_signals():
	if Engine.has_singleton("OVRMobile"):
		var singleton = Engine.get_singleton("OVRMobile")
		print("Connecting to OVRMobile signals")
		singleton.connect("HeadsetMounted", self, "_on_headset_mounted")
		singleton.connect("HeadsetUnmounted", self, "_on_headset_unmounted")
		singleton.connect("InputFocusGained", self, "_on_input_focus_gained")
		singleton.connect("InputFocusLost", self, "_on_input_focus_lost")
		singleton.connect("EnterVrMode", self, "_on_enter_vr_mode")
		singleton.connect("LeaveVrMode", self, "_on_leave_vr_mode")
	else:
		print("Unable to load OVRMobile singleton...")


func _on_headset_mounted():
	print("VR headset mounted")


func _on_headset_unmounted():
	print("VR headset unmounted")


func _on_input_focus_gained():
	print("Input focus gained")


func _on_input_focus_lost():
	print("Input focus lost")


func _on_enter_vr_mode():
	print("Entered Oculus VR mode")


func _on_leave_vr_mode():
	print("Left Oculus VR mode")


# here we can react on the android specific notifications
# reacting on NOTIFICATION_APP_RESUMED is necessary as the OVR context will get
# recreated when the Android device wakes up from sleep and then all settings will
# need to be reapplied
func _notification(what):
	if (what == NOTIFICATION_APP_RESUMED):
		_performed_runtime_config = false # redo runtime config


func _check_and_perform_runtime_config():
	if _performed_runtime_config: return

	if (ovr_performance):
		# these are some examples of using the ovr .gdns APIs
		ovr_performance.set_clock_levels(1, 1)
		ovr_performance.set_enable_dynamic_foveation(true);  # Enable dynamic foveation
		if (ovr_system and ovr_system.is_oculus_quest_2_device()):
			ovr_performance.set_extra_latency_mode(ovrVrApiTypes.OvrExtraLatencyMode.VRAPI_EXTRA_LATENCY_MODE_OFF)
		else:
			ovr_performance.set_extra_latency_mode(ovrVrApiTypes.OvrExtraLatencyMode.VRAPI_EXTRA_LATENCY_MODE_ON)

	_performed_runtime_config = true

