extends Area2D

var speed = 500.0

func _ready():
	pass
	
func _process(delta):
	position.y -= speed * delta 


func _on_Bullet_area_entered(area):
	if !area.is_in_group("Enemies"): return
	area.die()
