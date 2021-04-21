extends Control

export var card: PackedScene = preload("res://scenes/card.tscn")

var next_card = null

func _ready():
	$CardContainer/Card.enabled = true

func _on_Card_moving():
	if $CardContainer.get_child_count() != 1: return
	var instance = card.instance()
	$CardContainer.add_child(instance)
	$CardContainer.move_child(instance, 0)
	next_card = instance
	instance.connect("moving", self, "_on_Card_moving")
	instance.connect("finished", self, "_on_Card_finished")

func _on_Card_finished():
	next_card.enabled = true
