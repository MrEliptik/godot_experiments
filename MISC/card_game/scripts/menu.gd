extends Control

func _ready() -> void:
	pass 

func _on_CardPlaceA_card_inserted() -> void:
	$Particles2D.emitting = true
	
func _on_CardPlaceA_card_removed() -> void:
	$Particles2D.emitting = false

func _on_CardPlaceB_card_inserted() -> void:
	pass # Replace with function body.



