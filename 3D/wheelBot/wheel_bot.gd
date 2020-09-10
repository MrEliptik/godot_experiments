extends KinematicBody

const ROTATION_SPEED = 20
const MAX_ANGLE = 35

var gravity = -9.8
var velocity = Vector3()


const SPEED = 10
const ROT_SPEED = 2
const ACCELERATION = 30
const DE_ACCELERATION = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	velocity.y += gravity * delta
	get_input(delta)
	
	if velocity.x > 0:
		$AnimationPlayer.play("forward")
		if $Cube.rotation_degrees.z > -MAX_ANGLE:
			$Cube.rotation_degrees.z -= delta * ROTATION_SPEED
	else:
		$AnimationPlayer.stop()
		if $Cube.rotation_degrees.z <= 0:
			$Cube.rotation_degrees.z += delta * ROTATION_SPEED
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	

func get_input(delta):
	var vy = velocity.y
	velocity = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity += transform.basis.x * SPEED
	if Input.is_action_pressed("ui_down"):
		velocity += -transform.basis.x * SPEED
	if Input.is_action_pressed("ui_right"):
		rotate_y(-ROT_SPEED * delta)
	if Input.is_action_pressed("ui_left"):
		rotate_y(ROT_SPEED * delta)
	velocity.y = vy
