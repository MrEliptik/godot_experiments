extends Spatial

const hook = preload("res://scenes/graplingHook.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Player_hook(who_a, who_b, where):
	var instance = hook.instance()
	add_child(instance)
	instance.attach(who_a, who_b, where)
