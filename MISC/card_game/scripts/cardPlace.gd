extends TextureRect

signal card_inserted()
signal card_removed()

var curr_card = null

func _ready() -> void:
	pass

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Cards"):
		area.get_parent().capture(rect_global_position)
		curr_card = area.get_parent()
		curr_card.connect("placed", self, "on_card_inserted")

func _on_Area2D_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Cards"):
		area.get_parent().release()
		curr_card.disconnect("placed", self, "on_card_inserted")
		curr_card = null
		emit_signal("card_removed")
		
func on_card_inserted():
	emit_signal("card_inserted")
