extends Node2D

onready var bus = AudioServer.get_bus_index("Master")

var buf = null
var first_draw = true

var margin_h = 100
var margin_v = 50

var left_db = 0
var right_db = 0

var values_left: Array
var values_right: Array

var started = false

func _ready():
	buf = StreamPeerBuffer.new()
	buf.data_array = $AudioStreamPlayer.stream.data
	var data = $AudioStreamPlayer.stream.data
	
	var stream = $AudioStreamPlayer.get_stream_playback()
	
	print(data.size())
	print(stream)
	print(buf.data_array.size())
	
#	for i in range(buf.data_array.size()):
#		print(buf.get_float())

	update()

func _draw():
	# Base line
	draw_line(Vector2(0, 1080/2), Vector2(1920, 1080/2), Color(1, 1, 1), 10, true)
	
	draw_set_transform(Vector2(margin_h, 0), 0, Vector2(1, 1))
	
	var data_size = values_left.size()
	if data_size == 0: return
	
	var bar_size = 1920.0 / data_size
	
	# Left
	for i in range(values_left.size()):
		#draw_line(Vector2(i + (bar_size*i), 1080/2), Vector2(i + (bar_size*i), (1080/2) * (1 - values_left[i])), Color(1, 1, 1), bar_size, true)
		draw_line(Vector2(i, 1080/2), Vector2(i, (1080/2) * (1 - values_left[i])), Color(1, 1, 1), 1, true)
	
	# Right
	for i in range(values_right.size()):
		#draw_line(Vector2(i + (bar_size*i), 1080/2), Vector2(i + (bar_size*i), (1080/2) + (1080/2) * values_right[i]), Color(1, 1, 1), bar_size, true)
		draw_line(Vector2(i, 1080/2), Vector2(i, (1080/2) + ((1080/2) * values_right[i])), Color(1, 1, 1), 1, true)


func _process(delta):
	
	if Input.is_action_just_pressed("ui_accept"):
		started = true
		$AudioStreamPlayer.play()
	
	if !started: return
	
	left_db = AudioServer.get_bus_peak_volume_left_db(bus, 0)
	right_db = AudioServer.get_bus_peak_volume_right_db(bus, 0)
	values_left.append(db2linear(left_db))
	values_right.append(db2linear(right_db))

	update()
