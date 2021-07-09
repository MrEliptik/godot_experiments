extends Node2D

const dot_scene = preload("res://scenes/dot.tscn")

export var dots_number: int = 50
export var line_color: Color = Color("#ffffffff")
export var line_width: float = 1.0
export var max_distance: float = 100.0

func _ready():
	randomize()
	
	for i in range(dots_number):
		var instance = dot_scene.instance()
		$DotsContainer.add_child(instance)
		instance.global_position = Vector2(int(rand_range(20, 1900)), int(rand_range(20, 1060)))
	
	# Because they all share the same collisionshape, I only need to 
	# update one of the dot
	$DotsContainer.get_child(0).get_node("Area2D/CollisionShape2D").shape.radius = max_distance
	
func _draw():
	for dot in $DotsContainer.get_children():
		if dot.close_dots.size() == 0: continue
		for close_dot in dot.close_dots:
			# Calculate color based on distance
			var dist = abs(dot.position.distance_to(close_dot.position))
			line_color.a = lerp(0.0, 1.0, 1/(max_distance/dist))
			draw_line(dot.position, close_dot.position, line_color, line_width, true)
	
func _process(delta):
	update()
