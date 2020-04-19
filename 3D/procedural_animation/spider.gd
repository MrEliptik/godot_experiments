extends Spatial

onready var targets = $Targets

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physic_process(delta):
	for target in targets.get_children():
		# Raycast from target to level it with floor
		
		# Calculate distance from target and actual leg postion
		target.distance_to()
		
		# If distance too big, move the leg to target
		
		# 
