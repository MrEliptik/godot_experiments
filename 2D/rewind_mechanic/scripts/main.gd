extends Node2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("rewind"):
		rewind()
		
func rewind() -> void:
	$Player.rewind()
	$Box.rewind()
	
	$CanvasLayer/HBoxContainer.visible = true
	yield(get_tree().create_timer(3.0), "timeout")
	$CanvasLayer/HBoxContainer.visible = false
