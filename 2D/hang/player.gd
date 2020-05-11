extends RigidBody2D

onready var ray = $RayCast2D

signal anchor(point, collider)
signal free

var anchor = null

var reset = false
var reset_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	update()
	if !reset: contact_monitor = true
	
func _integrate_forces(state):
	if reset:
		state.transform = Transform2D(0, reset_position)
		state.linear_velocity = Vector2()
		reset = false
	
func _draw():
	if anchor != null:
		draw_line(ray.position, (ray.get_collision_point()-ray.global_position).rotated(-rotation), Color(1, 1, 1), 2)
	#else:
	#	draw_line(ray.position, ray.cast_to.rotated(-rotation), Color(0, 1, 0), 2)

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
		
func reset(pos):
	reset = true
	reset_position = pos
	anchor = null

func _on_Player_body_entered(body):
	if reset: return
	print('dead')
	get_tree().reload_current_scene()
