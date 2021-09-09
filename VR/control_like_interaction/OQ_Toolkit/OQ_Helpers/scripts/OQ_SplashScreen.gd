extends Spatial

var currentPosition;
var movePosition;
var targetPosition;
var distance =  3.0;
var time_to_move = 0.5;

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewDir = -vr.vrCamera.global_transform.basis.z;
	var camPos = vr.vrCamera.global_transform.origin;
	currentPosition = camPos + viewDir * distance;
	targetPosition = currentPosition;
	movePosition = currentPosition;
	
	look_at_from_position(currentPosition, camPos, Vector3(0,1,0));
	
	pass # Replace with function body.

var moving = false;
var moveTimer = 0.0;

func _process(dt):
	var viewDir = -vr.vrCamera.global_transform.basis.z;
	viewDir.y = 0.0;
	viewDir = viewDir.normalized();
	
	var camPos = vr.vrCamera.global_transform.origin;

	#TODO: rotate instead of move
	targetPosition = camPos + viewDir * distance;
	var distToTarget = (targetPosition - currentPosition).length();
	if moving:
		currentPosition = currentPosition + (movePosition - currentPosition) * dt;
		if (distToTarget < 0.05):
			moving = false;

			
	if (distToTarget > 0.5):
		moveTimer += dt;
	else:
		moveTimer = 0.0;
			
	if (moveTimer > time_to_move):
		moving = true;
		movePosition = targetPosition;

	look_at_from_position(currentPosition, camPos, Vector3(0,1,0));
