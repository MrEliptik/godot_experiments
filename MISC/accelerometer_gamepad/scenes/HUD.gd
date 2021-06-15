extends Control

func _ready():
	pass
	
func set_values(x, y, z):
	$GridContainer/XValue.text = str(x)
	$GridContainer/YValue.text = str(y)
	$GridContainer/ZValue.text = str(z)
