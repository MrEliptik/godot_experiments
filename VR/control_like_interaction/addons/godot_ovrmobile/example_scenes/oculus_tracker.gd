class_name OculusTracker
extends ARVRController
# Contains common logic and functionality for the ARVR positional tracker 
# supported by Oculus.


# Controller ids for the left and right trackers.
const LEFT_TRACKER_ID = 1
const RIGHT_TRACKER_ID = 2

var _remove_tracker_on_first_frame = false

# Parent node for the touch controller. This will be used to remove this node 
# when the tracker is removed.
onready var origin : ARVROrigin = get_parent()

func _ready():
	_initialize_trackers()


func _process(delta):
	if (_remove_tracker_on_first_frame):
		origin.remove_child(self)
		_remove_tracker_on_first_frame = false


func _initialize_trackers():
	# Hide the tracker and set up a flag to remove it from the scene tree. This is done so the node is
	# disabled until the tracked hand is detected by the Oculus system.
	visible = false
	_remove_tracker_on_first_frame = true

	# Connect to trackers updates signals so we're notified when the Oculus system detects a tracked
	# hand.
	ARVRServer.connect("tracker_added", self, "_on_arvr_tracker_added")
	ARVRServer.connect("tracker_removed", self, "_on_arvr_tracker_removed")


func _on_arvr_tracker_added(tracker_name, type, id):
	_enable_tracker(tracker_name, true)


func _on_arvr_tracker_removed(tracker_name, type, id):
	_enable_tracker(tracker_name, false)


# If true, enable the tracker by making it visible and adding it to the scene tree.
# If false, disable the tracker by removing it from the scene tree and making it invisible.
func _enable_tracker(tracker_name, enabled):
	if (_get_tracker_label() == tracker_name):
		if (enabled):
			print("Enabled " + _get_tracker_label())
			if (!origin.is_a_parent_of(self)):
				origin.add_child(self)
			visible = true
		else:
			print("Disabled " + _get_tracker_label())
			visible = false
			if (origin.is_a_parent_of(self)):
				origin.remove_child(self)


func _get_tracker_label():
	return "Oculus Tracker"
