extends Control

onready var level = $LevelLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	set_hooks(-1)

func set_level(level_nb):
	level.text = "Level " + str(level_nb)

func set_hooks(hooks_nb):
	if hooks_nb != -1:
		$HBoxContainer/HooksLabel.text = str(hooks_nb)
	else:
		$HBoxContainer/HooksLabel.text = str("∞")
