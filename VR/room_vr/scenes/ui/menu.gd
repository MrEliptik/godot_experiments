extends Control

onready var time = $VBoxContainer/Time

func _ready():
	update_time()
	
func update_time():
	var timeDict = OS.get_time()
	var hour = timeDict.hour
	var minute = timeDict.minute
	var second = timeDict.second
	# %02d will zero-pad each value to be 2 digits wide
	time.text = "%02d:%02d:%02d" % [hour, minute, second]

func _on_TimeUpdate_timeout():
	update_time()
