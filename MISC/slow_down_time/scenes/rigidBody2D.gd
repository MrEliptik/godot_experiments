extends RigidBody2D

var slow_factor = 1.0
onready var original_gravity_scale = gravity_scale

func _ready():
	pass

func slow_down(val, factor):
	slow_factor = factor
	gravity_scale = original_gravity_scale * factor
