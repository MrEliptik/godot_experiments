extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var speed: float = 600.0
var dir: Vector2 = Vector2.ZERO

var replay_duration: float = 3.0
var rewinding: bool = false
var rewind_values = {
	"position": [],
	"rotation": [],
	"velocity": [],
}

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if rewinding: return
	dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	dir = dir.normalized()
	
	look_at(get_global_mouse_position())
	
func _physics_process(delta: float) -> void:
	velocity = dir * speed
	velocity = move_and_slide(velocity)
	
	if not rewinding:
		if replay_duration * Engine.iterations_per_second == rewind_values["position"].size():
			# Remove the oldest value, to append a new one
			for key in rewind_values.keys():
				rewind_values[key].pop_front()
				
		rewind_values["position"].append(global_position)
		rewind_values["rotation"].append(rotation)
		rewind_values["velocity"].append(velocity)
	else:
		compute_rewind(delta)

func compute_rewind(delta: float) -> void:
	var pos = rewind_values["position"].pop_back()
	var rot = rewind_values["rotation"].pop_back()
	# We dont have any position left, we stop rewinding
	if rewind_values["position"].empty():
		$CollisionShape2D.set_deferred("disabled", false)
		rewinding = false
		global_position = pos
		rotation = rot
		velocity = rewind_values["velocity"][0]
		return
	
	rotation = rot
	global_position = pos

func rewind() -> void:
	rewinding = true
	$CollisionShape2D.set_deferred("disabled", true)
	
