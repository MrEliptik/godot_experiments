extends "res://scenes/tree.gd"


func _ready():
	pass
	
func die():
	$TreeShape.disabled = true
	$StumpShape.disabled = false
	$FullTree.visible = false
	$stump.visible = true
	
	var dying = true
	
	# Call inherited function
	.die()
