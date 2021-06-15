extends Control

func _ready():
	pass
	
func set_ip(ip):
	$MarginContainer/HBoxContainer/ClientIP.text = ip
	
func set_status(status):
	$MarginContainer/HBoxContainer/Status.text = status

func set_started(val):
	$Started.visible = !val
