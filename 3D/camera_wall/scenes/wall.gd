extends CSGBox

var cam_visible = true

var visibile_speed = 0.1
var hide_speed = 0.3

func _ready():
	pass 
	
func _process(_delta):
	if cam_visible:
		material.albedo_color = lerp(material.albedo_color, Color("#7a0e0e"), visibile_speed)
	else:
		material.albedo_color = lerp(material.albedo_color, Color("#007a0e0e"), hide_speed) 

	# By default, the wall should be visible
	cam_visible = true
	
func set_visible(val):
	cam_visible = val

