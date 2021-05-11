extends Node2D

export var slow_factor = 0.05
export var simple = preload("res://scenes/slowdownSimple.tscn")
export var custom = preload("res://scenes/slowdownCustom.tscn")

onready var first_time = OS.get_ticks_msec()

func _ready():
	pass
	
func _process(delta):
	$CanvasLayer/HUD.set_delta(delta)
	$CanvasLayer/HUD.set_time(OS.get_ticks_msec() - first_time)

func _on_HUD_slow_pressed(val):
	$Scene.get_child(0).slow_down(val, slow_factor)
	if val:
		$CanvasLayer/HUD.set_slow_factor(slow_factor)
	else:
		$CanvasLayer/HUD.set_slow_factor(1.0)

func _on_HUD_next_pressed():
	if $Scene.get_child(0).get_name() == "SlowdownSimple":
		$Scene.get_child(0).call_deferred("queue_free")
		var instance = custom.instance()
		$Scene.add_child(instance)
		$CanvasLayer/HUD.set_title("Slow down custom")
		$CanvasLayer/HUD.set_next_btn("Slow down simple >")
	else:
		$Scene.get_child(0).call_deferred("queue_free")
		var instance = simple.instance()
		$Scene.add_child(instance)
		$CanvasLayer/HUD.set_title("Slow down simple")
		$CanvasLayer/HUD.set_next_btn("Slow down custom >")
