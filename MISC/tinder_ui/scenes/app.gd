extends Control

export var card: PackedScene = preload("res://scenes/card.tscn")
export var match_scene: PackedScene = preload("res://scenes/matchScreen.tscn")

var next_card = null

func _ready():
	randomize()
	$CardContainer/Card.enabled = true

func _on_Card_moving():
	if $CardContainer.get_child_count() != 1: return
	var instance = card.instance()
	$CardContainer.add_child(instance)
	$CardContainer.move_child(instance, 0)
	next_card = instance
	instance.connect("moving", self, "_on_Card_moving")
	instance.connect("finished", self, "_on_Card_finished")
	instance.connect("like", self, "on_card_liked")
	instance.connect("dislike", self, "on_card_disliked")

func _on_Card_finished():
	next_card.enabled = true

func on_card_liked(card, im):
	if randf() < 0.1:
		# It's a match!
		var instance = match_scene.instance()
		$MatchContainer.add_child(instance)
		instance.set_image(im)
		instance.connect("keep_swiping", self, "on_keep_swiping")
	
func on_card_disliked(card):
	pass
	
func on_keep_swiping():
	$MatchContainer.get_child(0).call_deferred("queue_free")
