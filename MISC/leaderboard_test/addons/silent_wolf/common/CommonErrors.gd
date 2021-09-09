extends Node

const SWLogger = preload("../utils/SWLogger.gd")

func _ready():
	pass
	
static func check_status_code(status_code):
	SWLogger.debug("status_code: " + str(status_code))
	var check_ok = true
	if status_code == 0:
		no_connection_error()
		check_ok = false
	return check_ok

static func no_connection_error():
	SWLogger.error("Godot couldn't connect to the SilentWolf backend. This is probably due to custom SSL configuration in Project Settings > Network > SSL. See https://silentwolf.com/troubleshooting for more details.")
