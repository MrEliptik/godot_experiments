extends Node

static func get_log_level():
	var log_level = 1
	if SilentWolf.config.has('log_level'):
		log_level = SilentWolf.config.log_level
	else:
		error("Couldn't find SilentWolf.config.log_level, defaulting to 1") 
	return log_level
	
static func error(text):
	printerr(str(text))
	push_error(str(text))

static func info(text):
	if get_log_level() > 0:
		print(str(text))
	
static func debug(text):
	if get_log_level() > 1:
		print(str(text))
