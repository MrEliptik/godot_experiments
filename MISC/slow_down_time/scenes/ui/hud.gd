extends Control

signal slow_pressed(val)
signal next_pressed()

func _ready():
	pass
	
func set_title(title):
	$GridContainer/Title.text = title
	
func set_next_btn(text):
	$HBoxContainer/NextBtn.text = text
	
func set_delta(val):
	$GridContainer/Delta.text = str(val)
	
func set_time(val):
	$GridContainer/Time.text = str(val)
	
func set_slow_factor(val):
	$GridContainer/SlowFactor.text = str(val)

func _on_SlowBtn_toggled(button_pressed):
	if button_pressed:
		$HBoxContainer/SlowBtn.text = "NORMAL SPEED"
	else:
		$HBoxContainer/SlowBtn.text = "SLOW DOWN"
	emit_signal("slow_pressed", button_pressed)

func _on_NextBtn_pressed():
	emit_signal("next_pressed")
