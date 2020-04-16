extends Spatial

signal pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Area_body_entered(body):
	if body.name == 'Button':
		emit_signal('pressed')

func _on_Button_body_entered(body):
	print('Contact with: ' + body.name)
