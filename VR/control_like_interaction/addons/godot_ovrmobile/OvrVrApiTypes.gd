# these enums are taken from VrApi_Types.h version 1.26.0 for gdscript use; 
# for further documentation check the VrApi_Types.h file in the oculus mobile sdk

enum OvrDeviceType {
	VRAPI_DEVICE_TYPE_GEARVR_START			= 0,

	VRAPI_DEVICE_TYPE_NOTE4					= 0, #VRAPI_DEVICE_TYPE_GEARVR_START,
	VRAPI_DEVICE_TYPE_NOTE5					= 1,
	VRAPI_DEVICE_TYPE_S6					= 2,
	VRAPI_DEVICE_TYPE_S7					= 3,
	VRAPI_DEVICE_TYPE_NOTE7					= 4,			#< No longer supported.
	VRAPI_DEVICE_TYPE_S8					= 5,
	VRAPI_DEVICE_TYPE_NOTE8					= 6,
	VRAPI_DEVICE_TYPE_NOTE7_FE				= 7,			#< Fan Edition
	VRAPI_DEVICE_TYPE_A8					= 8,
	VRAPI_DEVICE_TYPE_A8_PLUS				= 9,
	VRAPI_DEVICE_TYPE_S9					= 10,
	VRAPI_DEVICE_TYPE_S9_PLUS				= 11,
	VRAPI_DEVICE_TYPE_A8_STAR 				= 12,
	VRAPI_DEVICE_TYPE_NOTE9           		= 13,
	VRAPI_DEVICE_TYPE_A9_2018				= 14,
	VRAPI_DEVICE_TYPE_S10					= 15,
	VRAPI_DEVICE_TYPE_GEARVR_END			= 63,

	# Standalone Devices
	VRAPI_DEVICE_TYPE_OCULUSGO_START		= 64,
	VRAPI_DEVICE_TYPE_OCULUSGO				= 64, #VRAPI_DEVICE_TYPE_OCULUSGO_START,
	VRAPI_DEVICE_TYPE_MIVR_STANDALONE		= 64 + 1, #VRAPI_DEVICE_TYPE_OCULUSGO_START + 1,	#< China-only SKU
	VRAPI_DEVICE_TYPE_OCULUSGO_END			= 127,

	VRAPI_DEVICE_TYPE_OCULUSQUEST_START		= 256,
	VRAPI_DEVICE_TYPE_OCULUSQUEST			= 256 + 3, #VRAPI_DEVICE_TYPE_OCULUSQUEST_START + 3,
	VRAPI_DEVICE_TYPE_OCULUSQUEST_END		= 319,

	VRAPI_DEVICE_TYPE_UNKNOWN				= -1,
}

##/ A headset, which typically includes optics and tracking hardware, but not necessarily the device itself.
enum OvrHeadsetType {
	VRAPI_HEADSET_TYPE_R320					= 0,			#< Note4 Innovator
	VRAPI_HEADSET_TYPE_R321					= 1,			#< S6 Innovator
	VRAPI_HEADSET_TYPE_R322					= 2,			#< Commercial 1
	VRAPI_HEADSET_TYPE_R323					= 3,			#< Commercial 2 (USB Type C)
	VRAPI_HEADSET_TYPE_R324					= 4,			#< Commercial 3 (USB Type C)
	VRAPI_HEADSET_TYPE_R325					= 5,			#< Commercial 4 2017 (USB Type C)

	# Standalone Headsets
	VRAPI_HEADSET_TYPE_OCULUSGO				= 64,			#< Oculus Go
	VRAPI_HEADSET_TYPE_MIVR_STANDALONE		= 65,			#< China-only SKU

	VRAPI_HEADSET_TYPE_OCULUSQUEST			= 256,


	VRAPI_HEADSET_TYPE_UNKNOWN				= -1,
}

##/ A geographic region authorized for certain hardware and content.
enum OvrDeviceRegion {
	VRAPI_DEVICE_REGION_UNSPECIFIED	= 0,
	VRAPI_DEVICE_REGION_JAPAN		= 1,
	VRAPI_DEVICE_REGION_CHINA		= 2,
}

enum OvrDeviceEmulationMode {
	VRAPI_DEVICE_EMULATION_MODE_NONE		= 0,
	VRAPI_DEVICE_EMULATION_MODE_GO_ON_QUEST	= 1,
}



enum OvrProperty {
	VRAPI_FOVEATION_LEVEL 								= 15, #< Used by apps that want to control swapchain foveation levels.
	VRAPI_REORIENT_HMD_ON_CONTROLLER_RECENTER 			= 17, #< Used to determine if a controller recenter should also reorient the headset.
	VRAPI_LATCH_BACK_BUTTON_ENTIRE_FRAME 				= 18, #< Used to determine if the 'short press' back button should lasts an entire frame.
	VRAPI_BLOCK_REMOTE_BUTTONS_WHEN_NOT_EMULATING_HMT 	= 19, #< Used to not send the remote back button java events to the apps.
	VRAPI_ACTIVE_INPUT_DEVICE_ID 						= 24, #< Used by apps to query which input device is most 'active' or primary, a# -1 means no active input device
	VRAPI_DEVICE_EMULATION_MODE 						= 29, #< Used by apps to determine if they are running in an emulation mode. Is a OvrDeviceEmulationMode value
}

enum OvrHandedness {
	VRAPI_HAND_UNKNOWN	= 0,
	VRAPI_HAND_LEFT		= 1,
	VRAPI_HAND_RIGHT	= 2
}

enum OvrSystemProperty {
	VRAPI_SYS_PROP_DEVICE_TYPE								= 0,
	VRAPI_SYS_PROP_MAX_FULLSPEED_FRAMEBUFFER_SAMPLES		= 1,
	# Physical width and height of the display in pixels.
	VRAPI_SYS_PROP_DISPLAY_PIXELS_WIDE						= 2,
	VRAPI_SYS_PROP_DISPLAY_PIXELS_HIGH						= 3,
	# Returns the refresh rate of the display in cycles per second.
	VRAPI_SYS_PROP_DISPLAY_REFRESH_RATE						= 4,
	# With a display resolution of 2560x1440, the pixels at the center
	# of each eye cover about 0.06 degrees of visual arc. To wrap a
	# full 360 degrees, about 6000 pixels would be needed and about one
	# quarter of that would be needed for ~90 degrees FOV. As such, Eye
	# images with a resolution of 1536x1536 result in a good 1:1 mapping
	# in the center, but they need mip-maps for off center pixels. To
	# avoid the need for mip-maps and for significantly improved rendering
	# performance this currently returns a conservative 1024x1024.
	VRAPI_SYS_PROP_SUGGESTED_EYE_TEXTURE_WIDTH				= 5,
	VRAPI_SYS_PROP_SUGGESTED_EYE_TEXTURE_HEIGHT				= 6,
	# This is a product of the lens distortion and the screen size,
	# but there is no truly correct answer.
	# There is a tradeoff in resolution and coverage.
	# Too small of an FOV will leave unrendered pixels visible, but too
	# large wastes resolution or fill rate.  It is unreasonable to
	# increase it until the corners are completely covered, but we do
	# want most of the outside edges completely covered.
	# Applications might choose to render a larger FOV when angular
	# acceleration is high to reduce black pull in at the edges by
	# the time warp.
	# Currently symmetric 90.0 degrees.
	VRAPI_SYS_PROP_SUGGESTED_EYE_FOV_DEGREES_X				= 7,
	VRAPI_SYS_PROP_SUGGESTED_EYE_FOV_DEGREES_Y				= 8,
	# Path to the external SD card. On Android-M, this path is dynamic and can
	# only be determined once the SD card is mounted. Returns an empty string if
	# device does not support an ext sdcard or if running Android-M and the SD card
	# is not mounted.
	VRAPI_SYS_PROP_EXT_SDCARD_PATH							= 9,
	VRAPI_SYS_PROP_DEVICE_REGION							= 10,
	# Video decoder limit for the device.
	VRAPI_SYS_PROP_VIDEO_DECODER_LIMIT						= 11,
	VRAPI_SYS_PROP_HEADSET_TYPE								= 12,

	# enum 13 used to be VRAPI_SYS_PROP_BACK_BUTTON_SHORTPRESS_TIME
	# enum 14 used to be VRAPI_SYS_PROP_BACK_BUTTON_DOUBLETAP_TIME

	# Returns an OvrHandedness enum indicating left or right hand.
	VRAPI_SYS_PROP_DOMINANT_HAND							= 15,

	# Returns the number of display refresh rates supported by the system.
	VRAPI_SYS_PROP_NUM_SUPPORTED_DISPLAY_REFRESH_RATES		= 64,
	# Returns an array of the supported display refresh rates.
	VRAPI_SYS_PROP_SUPPORTED_DISPLAY_REFRESH_RATES			= 65,

	# Returns the number of swapchain texture formats supported by the system.
	VRAPI_SYS_PROP_NUM_SUPPORTED_SWAPCHAIN_FORMATS			= 66,
	# Returns an array of the supported swapchain formats.
	# Formats are platform specific. For GLES, this is an array of
	# GL internal formats.
	VRAPI_SYS_PROP_SUPPORTED_SWAPCHAIN_FORMATS				= 67,

	# Returns VRAPI_TRUE if Multiview rendering support is available for this system,
	# otherwise VRAPI_FALSE.
	VRAPI_SYS_PROP_MULTIVIEW_AVAILABLE						= 128,

	# Returns VRAPI_TRUE if submission of SRGB Layers is supported for this system,
	# otherwise VRAPI_FALSE.
	VRAPI_SYS_PROP_SRGB_LAYER_SOURCE_AVAILABLE				= 129,

	# Returns VRAPI_TRUE if on-chip foveated rendering of swapchains is supported
	# for this system, otherwise VRAPI_FALSE.
	VRAPI_SYS_PROP_FOVEATION_AVAILABLE						= 130,
}

enum OvrSystemStatus {
	VRAPI_SYS_STATUS_DOCKED							= 0,	#< Device is docked.
	VRAPI_SYS_STATUS_MOUNTED						= 1,	#< Device is mounted.
	VRAPI_SYS_STATUS_THROTTLED						= 2,	#< Device is in powersave mode.
	# enum  3 used to be VRAPI_SYS_STATUS_THROTTLED2.
	# enum  4 used to be VRAPI_SYS_STATUS_THROTTLED_WARNING_LEVEL.
	VRAPI_SYS_STATUS_RENDER_LATENCY_MILLISECONDS	= 5,	#< Average time between render tracking sample and scanout.
	VRAPI_SYS_STATUS_TIMEWARP_LATENCY_MILLISECONDS	= 6,	#< Average time between timewarp tracking sample and scanout.
	VRAPI_SYS_STATUS_SCANOUT_LATENCY_MILLISECONDS	= 7,	#< Average time between Vsync and scanout.
	VRAPI_SYS_STATUS_APP_FRAMES_PER_SECOND			= 8,	#< Number of frames per second delivered through vrapi_SubmitFrame.
	VRAPI_SYS_STATUS_SCREEN_TEARS_PER_SECOND		= 9,	#< Number of screen tears per second (per eye).
	VRAPI_SYS_STATUS_EARLY_FRAMES_PER_SECOND		= 10,	#< Number of frames per second delivered a whole display refresh early.
	VRAPI_SYS_STATUS_STALE_FRAMES_PER_SECOND		= 11,	#< Number of frames per second delivered late.
	# enum 12 used to be VRAPI_SYS_STATUS_HEADPHONES_PLUGGED_IN
	VRAPI_SYS_STATUS_RECENTER_COUNT					= 13,	#< Returns the current HMD recenter count. Defaults to 0.
	VRAPI_SYS_STATUS_SYSTEM_UX_ACTIVE				= 14,	#< Returns VRAPI_TRUE if a system UX layer is active
	VRAPI_SYS_STATUS_USER_RECENTER_COUNT			= 15,	#< Returns the current HMD recenter count for user initiated recenters only. Defaults to 0.

	VRAPI_SYS_STATUS_FRONT_BUFFER_PROTECTED			= 128,	#< VRAPI_TRUE if the front buffer is allocated in TrustZone memory.
	VRAPI_SYS_STATUS_FRONT_BUFFER_565				= 129,	#< VRAPI_TRUE if the front buffer is 16-bit 5:6:5
	VRAPI_SYS_STATUS_FRONT_BUFFER_SRGB				= 130,	#< VRAPI_TRUE if the front buffer uses the sRGB color space.
}


enum OvrTrackingTransform {
	VRAPI_TRACKING_TRANSFORM_IDENTITY					= 0,
	VRAPI_TRACKING_TRANSFORM_CURRENT					= 1,
	VRAPI_TRACKING_TRANSFORM_SYSTEM_CENTER_EYE_LEVEL	= 2,
	VRAPI_TRACKING_TRANSFORM_SYSTEM_CENTER_FLOOR_LEVEL	= 3,
}

enum OvrTrackingSpace {
	VRAPI_TRACKING_SPACE_LOCAL				= 0,	# Eye level origin - controlled by system recentering
	VRAPI_TRACKING_SPACE_LOCAL_FLOOR		= 1,	# Floor level origin - controlled by system recentering
	VRAPI_TRACKING_SPACE_LOCAL_TILTED		= 2,	# Tilted pose for "bed mode" - controlled by system recentering
	VRAPI_TRACKING_SPACE_STAGE				= 3,	# Floor level origin - controlled by Guardian setup
	VRAPI_TRACKING_SPACE_LOCAL_FIXED_YAW	= 7,	# Position of local space, but yaw stays constant
}

enum OvrTrackedDeviceTypeId {
	VRAPI_TRACKED_DEVICE_NONE 			= -1,
	VRAPI_TRACKED_DEVICE_HMD 			= 0,	#< Headset
	VRAPI_TRACKED_DEVICE_HAND_LEFT 		= 1,	#< Left controller
	VRAPI_TRACKED_DEVICE_HAND_RIGHT 	= 2,	#< Right controller
	VRAPI_NUM_TRACKED_DEVICES			= 3,
}


enum OvrExtraLatencyMode {
	VRAPI_EXTRA_LATENCY_MODE_OFF		= 0,
	VRAPI_EXTRA_LATENCY_MODE_ON			= 1,
	VRAPI_EXTRA_LATENCY_MODE_DYNAMIC	= 2
}
