extends Node2D

onready var ray = $RayCast2D

signal anchor(point, collider)
signal free

var anchor = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	update()
	print(rotation)
	
func _draw():
	if anchor != null:
		draw_line(ray.position, (ray.get_collision_point()-ray.global_position).rotated(-rotation), Color(255, 0, 0), 2)
	#else:
	#	draw_line(ray.position, ray.cast_to.rotated(-rotation), Color(0, 255, 0), 2)

func _input(e):
	if e is InputEventMouseButton && e.button_index == BUTTON_LEFT && e.pressed:	
		# Raycast to position
		ray.cast_to = (e.global_position-ray.global_position).rotated(-rotation)
		# Force update otherwise collision happens next frame
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			anchor = ray.get_collision_point()
			print(collider, anchor)
			emit_signal("anchor", anchor, collider)
		else:
			print("click: ", e.position)
	elif e is InputEventMouseButton && e.button_index == BUTTON_RIGHT && e.pressed:
		emit_signal("free")
		anchor = null
