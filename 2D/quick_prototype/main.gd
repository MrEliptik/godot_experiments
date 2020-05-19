extends Node2D

onready var wall = $Walls
onready var background = $Walls/Background

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	# Toggle invert property
	background.invert_enable = !background.invert_enable
