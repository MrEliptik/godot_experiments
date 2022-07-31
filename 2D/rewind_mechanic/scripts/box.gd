extends RigidBody2D

var rewind_values = {
	"transform": [],
	"linear_velocity": [],
	"angular_velocity": []
}
var rewind_duration: float = 3.0
var rewinding: bool = false

func _ready() -> void:
	pass
	
func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if not rewinding: return
	compute_rewind(state)
	
func compute_rewind(state: Physics2DDirectBodyState) -> void:
	var transf = rewind_values["transform"].pop_back()
	var angular_vel = rewind_values["angular_velocity"].pop_back()
	var linear_vel = rewind_values["linear_velocity"].pop_back()
		
	# We dont have any position left, we stop rewinding
	if rewind_values["transform"].empty():
		# Enable the collision
		$CollisionShape2D.set_deferred("disabled", false)
		rewinding = false
		
		# Apply the state
		state.linear_velocity = linear_vel
		state.angular_velocity = angular_vel
		state.transform = transf

		return
		
	# Apply the position
	state.transform = transf
	state.linear_velocity = Vector2.ZERO
	state.angular_velocity = 0.0

func _physics_process(delta: float) -> void:
	if not rewinding:
		if rewind_duration * Engine.iterations_per_second == rewind_values["transform"].size():
			# Remove the oldest value, to append a new one
			for key in rewind_values.keys():
				rewind_values[key].pop_front()
		
		rewind_values["transform"].append(global_transform)
		rewind_values["linear_velocity"].append(linear_velocity)
		rewind_values["angular_velocity"].append(angular_velocity)
	
func rewind() -> void:
	rewinding = true
	# Disable the collision
	$CollisionShape2D.set_deferred("disabled", true)
	
