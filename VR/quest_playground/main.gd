extends Spatial

onready var sphere = $Sphere
onready var log_window = $LogWindow

var right_pinching = false
var left_pinching = false

var initial_radius

var pinch_start_transform
var right_hand
var left_hand

var previous_distance = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	sphere.get_mesh().radius = 0.125
	sphere.get_mesh().height = 0.25
	sphere.get_node("StaticBody/CollisionShape").shape.radius = 0.125

func _process(delta):
	if right_pinching:
		var distance = pinch_start_transform.origin.distance_to(right_hand.global_transform.origin)
		#log_window._log('Distance: ' + str(distance) + str(abs(distance)))
		if distance > previous_distance:
			sphere.get_mesh().radius = initial_radius * (1 + distance)
			sphere.get_mesh().height = initial_radius * (1 + distance)
			sphere.get_node("StaticBody/CollisionShape").shape.radius = initial_radius * (1 + distance)
		else:
			sphere.get_mesh().radius = initial_radius * distance
			sphere.get_mesh().height = initial_radius * distance
			sphere.get_node("StaticBody/CollisionShape").shape.radius = initial_radius * distance
			
		previous_distance = distance

func _on_ARVROriginWithHandTrackingCustom_left_index_pinching(hand):
	sphere.get_surface_material(0).albedo_color = Color(randf(), randf(), randf())
	sphere.get_mesh().radius = 0.125
	sphere.get_mesh().height = 0.25
	sphere.get_node("StaticBody/CollisionShape").shape.radius = 0.125
	left_pinching = true
	left_hand = hand


func _on_ARVROriginWithHandTrackingCustom_right_index_pinching(hand):
	pinch_start_transform = hand.global_transform
	right_pinching = true
	right_hand = hand
	log_window._log('Right pinch start at: ' + str(pinch_start_transform))
	
#	sphere.get_mesh().radius = 0.25
#	sphere.get_mesh().height = 0.5
#	sphere.get_node("StaticBody/CollisionShape").shape.radius = 0.25

func _on_ARVROriginWithHandTrackingCustom_left_index_released(hand):
	left_pinching = false
	left_hand = null


func _on_ARVROriginWithHandTrackingCustom_right_index_released(hand):
	log_window._log('Right pinch stopped at: ' + 
		str(hand.global_transform.origin) + ' distance: ' + 
		str(pinch_start_transform.origin.distance_to(right_hand.global_transform.origin)))
	right_pinching = false
	right_hand = null
