extends Node2D

var draw_pos = Vector2(0, 0)

func _draw():
	for pos in draw_pos:
		draw_circle(pos, 100, Color.black)
	#draw_pos = null
	
func _process(delta):
	pass

func draw_at(pos):
	draw_pos = pos
	update()
