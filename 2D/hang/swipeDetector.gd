extends Node

signal swiped(direction)
signal swiped_canceled(start_position)

export(float, 1.0, 1.5) var MAX_DIAGONAL_SLOPE = 1.3

onready var timer = $Timer
var swipe_start_pos = Vector2()

func _ready():
	pass
	
func _input(event):
	if not event is InputEventScreenTouch: return
	
	if event.pressed:
		start_detection(event.position)
	elif not timer.is_stopped():
		end_detection(event.position)
	
func start_detection(pos):
	swipe_start_pos = pos
	timer.start()
	
func end_detection(pos):
	timer.stop()
	var direction = (pos - swipe_start_pos).normalized()
	if abs(direction.x) + abs(direction.y) >= MAX_DIAGONAL_SLOPE: return
	
	# Valid swipe
	# Horizontal
	if abs(direction.x) > abs(direction.y):
		emit_signal('swiped', Vector2(-sign(direction.x), 0))
	else:
		emit_signal('swiped', Vector2(0, -sign(direction.y)))

func _on_Timer_timeout():
	emit_signal("swiped_canceled", swipe_start_pos)
