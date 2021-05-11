extends Node2D

var slow_factor = 1.0
var old_slow_factor = slow_factor
var timer_wait_time = 1

func _ready():
	$Timer.wait_time = timer_wait_time
	
func _process(delta):
	# Scale by slow_factor to always get a value between 0 and timer_wait_time
	$Val.text = str($Timer.time_left*slow_factor)
	
func slow_down(val: bool, factor: float):
	slow_factor = factor
	var time_left = $Timer.time_left
	$Timer.stop()
	if val:
		# Change the wait time to reflect the time left scaled by the slow factor
		$Timer.wait_time = time_left * (1.0/slow_factor)
	else:
		$Timer.wait_time = time_left * (old_slow_factor)
		print($Timer.wait_time)
	old_slow_factor = slow_factor
	$Timer.start()
	
func _on_Timer_timeout():
	$Timer.stop()
	if slow_factor != 1.0:
		# Change the wait time to the original wait time scaled by the slow factor
		$Timer.wait_time = timer_wait_time * (1.0/slow_factor)
	else:
		$Timer.wait_time = timer_wait_time
	$Timer.start()
