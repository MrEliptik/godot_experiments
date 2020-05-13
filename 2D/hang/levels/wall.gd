extends StaticBody2D

onready var line = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var points = line.get_points()
	for x in range(len(points)):
		print(x, points[x])
		var segment = CollisionShape2D.new()
		segment.shape = SegmentShape2D.new()
		# If last point, we connect back to first point
		if x == len(points)-1:
			segment.shape.a = points[x]
			segment.shape.b = points[0]
		else:
			segment.shape.a = points[x]
			segment.shape.b = points[x+1]
		add_child(segment)

