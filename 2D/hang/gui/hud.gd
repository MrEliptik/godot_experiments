extends Control

onready var level = $LevelLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_level(level_nb):
	level.text = "Level " + str(level_nb)
