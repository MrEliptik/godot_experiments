extends Spatial

export var bullet_hit: PackedScene = preload("res://scenes/bulletHit.tscn")
export var water_speed = 8.0
export var water_particles = 5000

onready var mat = $Glass/Water.get_surface_material(0)

var min_pos_y := 0.5
var max_pos_y := 1.5
var water_level := 1.0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		refill()
		
		for x in get_tree().get_nodes_in_group("BulletHits"):
			x.call_deferred("queue_free")
		
func refill():
	water_level = 1.0
	mat.set_shader_param("water_level", water_level)
	$Glass/Water/WaterParticles.emitting = false

func _on_Area_input_event(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if !(event is InputEventMouseButton): return
	if event.button_index != 1 || !event.is_pressed(): return
	
	var instance = bullet_hit.instance()
	var global_pos = $Glass/Area.to_global(click_position)
	instance.connect("ready", self, "on_bullet_hit_ready", [instance, global_pos, global_pos - click_normal])
	call_deferred("add_child", instance)
	
	var hit_point = remap_range(click_position.y, min_pos_y, max_pos_y, 0.0, 1.0)
	var duration = abs(water_level - hit_point) * water_speed
	
	if hit_point > water_level: return
	
	$Glass/Water/WaterParticles.global_transform.origin = global_pos
	$Glass/Water/WaterParticles.emitting = true
	
	$Glass/Water/Tween.stop_all()
	$Glass/Water/Tween.interpolate_property(self, "water_level", water_level, 
		hit_point, duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Glass/Water/Tween.interpolate_property($Glass/Water/WaterParticles.process_material, "initial_velocity", 
		1.0, 0.25, duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Glass/Water/Tween.start()
	$Glass/Water/Timer.start(duration)
	
func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA
	
func on_bullet_hit_ready(node, global_pos, normal):
	node.global_transform.origin = global_pos
	node.look_at(normal, Vector3.UP)

func _on_Tween_tween_step(object: Object, key: NodePath, elapsed: float, value: Object) -> void:
	mat.set_shader_param("water_level", water_level)

func _on_Timer_timeout() -> void:
	$Glass/Water/WaterParticles.emitting = false
