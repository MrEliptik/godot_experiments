extends Area

export var impulse_factor = 1.0

var object_in_area = Array()
var picked_up_obj = null

var last_position = Vector3(0.0, 0.0, 0.0)
var velocity = Vector3(0.0, 0.0, 0.0)

# current button mapping for the touch controller
# godot itself also exposes some of these constants via JOY_VR_* and JOY_OCULUS_*
# this enum here is to document everything in place and includes the touch event mappings
enum CONTROLLER_BUTTON {
	YB = 1,
	GRIP_TRIGGER = 2, # grip trigger pressed over threshold
	ENTER = 3, # Menu Button on left controller

	TOUCH_XA = 5,
	TOUCH_YB = 6,

	XA = 7,

	TOUCH_THUMB_UP = 10,
	TOUCH_INDEX_TRIGGER = 11,
	TOUCH_INDEX_POINTING = 12,

	THUMBSTICK = 14, # left/right thumb stick pressed
	INDEX_TRIGGER = 15, # index trigger pressed over threshold
}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("button_pressed", self, "_on_button_pressed")
	last_position = global_transform.origin
	
func _process(delta):
	velocity = (global_transform.origin - last_position) / delta
	last_position = global_transform.origin
	
func _on_button_pressed(button):
	if (button == CONTROLLER_BUTTON.INDEX_TRIGGER):
		if picked_up_obj:
			# let go of this obj
			picked_up_obj.let_go(velocity * impulse_factor)
			picked_up_obj = null
		elif !object_in_area.empty():
			picked_up_obj = object_in_area[0]
			picked_up_obj.pick_up(self)
	
func _on_Pickup_body_entered(body):
	print("Pickup body entered: ", body)
	if body.has_method('pick_up') and object_in_area.find(body) == -1:
		object_in_area.push_back(body)

func _on_Pickup_body_exited(body):
	print("Pickup body exited: ", body)
	if object_in_area.find(body) != -1:
		object_in_area.erase(body)
