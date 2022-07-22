extends Node2D

func _ready() -> void:
	$Walls/CollisionPolygon2D.polygon = $Walls/Polygon2D.polygon

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("rewind"):
		rewind()
		
func rewind() -> void:
	$Player.rewind()
	$Ball.rewind()
	
	$CanvasLayer/HBoxContainer.visible = true
	yield(get_tree().create_timer(3.0), "timeout")
	$CanvasLayer/HBoxContainer.visible = false
