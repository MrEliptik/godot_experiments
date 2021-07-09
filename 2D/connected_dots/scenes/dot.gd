extends KinematicBody2D

export var radius: float = 5.0
export var color: Color = Color("#ffffff")
export var speed: float = 100.0

var close_dots = []

var velocity = Vector2.ZERO

func _ready():
	# Random rotation
	rotation_degrees = rand_range(0.0, 360.0)
	velocity = -transform.y * speed
	
func _draw():
	draw_circle(Vector2.ZERO, radius, color)
	
func _process(delta):
	update()
	
func _physics_process(delta):
	# Always move in its forward direction, bouncing off edges
	var collision = move_and_collide(velocity * delta)
	if !collision: return
	velocity = velocity.bounce(collision.normal)

func set_area_radius(radius):
	$Area2D/CollisionShape2D.shape.radius = radius

func _on_Area2D_area_entered(area):
	close_dots.append(area.get_parent())


func _on_Area2D_area_exited(area):
	close_dots.erase(area.get_parent())
