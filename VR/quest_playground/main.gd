extends Spatial

onready var sphere = $Sphere
onready var log_window = $LogWindow
onready var gestures_dash = $GestureDashboard

var right_pinching = false
var left_pinching = false

var initial_radius = 0
var initial_transform = 0

var pinch_start_transform
var left_pinch_start_transform
var right_hand
var left_hand

var previous_distance = 0
var previous_scale_distance = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	sphere.get_mesh().radius = 0.125
	sphere.get_mesh().height = 0.25
	sphere.get_node("StaticBody/CollisionShape").shape.radius = 0.125

func _process(delta):
	#	log_window._log('Right pinch start at: ' + str(pinch_start_transform)
#		+ ' right hand transgorm: ' + str(right_hand.global_transform.origin)
#		+ ' distance: ' + str(right_hand.global_transform.origin - pinch_start_transform))
	
	if left_pinching and right_pinching:

		var scale_distance = left_hand.global_transform.origin.distance_to(right_hand.global_transform.origin)
		#log_window._log('Distance: ' + str(distance) + str(abs(distance)))
		#if scale_distance > previous_scale_distance:
		sphere.get_mesh().radius = initial_radius * (1 + scale_distance)
		sphere.get_mesh().height = (initial_radius*2) * (1 + scale_distance)
		sphere.get_node("StaticBody/CollisionShape").shape.radius = initial_radius * (1 + scale_distance)
		#else:
#			sphere.get_mesh().radius = initial_radius * scale_distance
#			sphere.get_mesh().height = initial_radius * scale_distance
#			sphere.get_node("StaticBody/CollisionShape").shape.radius = initial_radius * scale_distance	
		previous_scale_distance = scale_distance
		
	elif right_pinching:
		var distance = right_hand.global_transform.origin - pinch_start_transform
		sphere.global_transform.origin = initial_transform + distance

func _on_ARVROriginWithHandTrackingCustom_left_index_pinching(hand):
#	sphere.get_surface_material(0).albedo_color = Color(randf(), randf(), randf())
#	sphere.get_mesh().radius = 0.125
#	sphere.get_mesh().height = 0.25
#	sphere.get_node("StaticBody/CollisionShape").shape.radius = 0.125
	left_pinch_start_transform = hand.global_transform.origin
	left_pinching = true
	left_hand = hand
	log_window._log('Left pinch start at: ' + str(left_pinch_start_transform))

func _on_ARVROriginWithHandTrackingCustom_left_index_released(hand):
	log_window._log('Left pinch stopped at: ' + 
		str(hand.global_transform.origin) + ' distance: ' + 
		str(left_hand.global_transform.origin - left_pinch_start_transform))
	left_pinching = false
	left_hand = null

func _on_ARVROriginWithHandTrackingCustom_right_index_pinching(hand):
	initial_radius = sphere.get_mesh().radius
	initial_transform = sphere.global_transform.origin 
	pinch_start_transform = hand.global_transform.origin
	right_pinching = true
	right_hand = hand
	log_window._log('Right pinch start at: ' + str(pinch_start_transform))

func _on_ARVROriginWithHandTrackingCustom_right_index_released(hand):
	log_window._log('Right pinch stopped at: ' + 
		str(hand.global_transform.origin) + ' distance: ' + 
		str(right_hand.global_transform.origin - pinch_start_transform))
	right_pinching = false
	right_hand = null


func _on_ARVROriginWithHandTrackingCustom_left_pinch(button):
	if (button == 7): gestures_dash.set_left_index_pinch(true)
	if (button == 1): gestures_dash.set_left_middle_pinch(true)
	if (button == 2): gestures_dash.set_left_pinky_pinch(true)
	if (button == 15): gestures_dash.set_left_ring_pinch(true)


func _on_ARVROriginWithHandTrackingCustom_left_release(button):
	if (button == 7): gestures_dash.set_left_index_pinch(false)
	if (button == 1): gestures_dash.set_left_middle_pinch(false)
	if (button == 2): gestures_dash.set_left_pinky_pinch(false)
	if (button == 15): gestures_dash.set_left_ring_pinch(false)


func _on_ARVROriginWithHandTrackingCustom_right_pinch(button):
	if (button == 7): gestures_dash.set_right_index_pinch(true)
	if (button == 1): gestures_dash.set_right_middle_pinch(true)
	if (button == 2): gestures_dash.set_right_pinky_pinch(true)
	if (button == 15): gestures_dash.set_right_ring_pinch(true)


func _on_ARVROriginWithHandTrackingCustom_right_release(button):
	if (button == 7): gestures_dash.set_right_index_pinch(false)
	if (button == 1): gestures_dash.set_right_middle_pinch(false)
	if (button == 2): gestures_dash.set_right_pinky_pinch(false)
	if (button == 15): gestures_dash.set_right_ring_pinch(false)
