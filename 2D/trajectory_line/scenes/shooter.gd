extends Polygon2D

export var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")

onready var trajectory_line: Line2D = $TrajectoryLine

var projectile_speed: float = 1200.0
var projectile_gravity: float = 1000.0

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		rotation -= delta
	elif Input.is_action_pressed("ui_right"):
		rotation += delta
	
	if Input.is_action_pressed("ui_up"):
		projectile_speed += 200 * delta
	elif Input.is_action_pressed("ui_down"):
		projectile_speed -= 200 * delta
		
	projectile_speed = clamp(projectile_speed, 100.0, 2000.0)

	if Input.is_action_just_pressed("ui_accept"):
		shoot()
		
	# Remove the rotation of the shooter from the line
	trajectory_line.rotation = -rotation
		
	trajectory_line.update_trajectory($ShootPos.global_transform.x, 
										projectile_speed, projectile_gravity, delta)
		
func shoot() -> void:
	var instance = projectile_scene.instance()
	instance.dir = $ShootPos.global_transform.x
	instance.speed = projectile_speed
	get_parent().add_child(instance)
	instance.global_position = $ShootPos.global_position
