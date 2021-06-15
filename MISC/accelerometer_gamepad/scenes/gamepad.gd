extends Control

onready var original_position = $Label/circle_bubble_inner.position

const GRAVITY: float = 9.8
const OFFSET_MAX: float = 620.0

onready var ws = $WSClient

func _ready():
	pass

func _process(delta):
	var accel = Input.get_accelerometer()
	$Label/circle_bubble_inner.position.x = 700 + (accel.x / GRAVITY * OFFSET_MAX)
	var data = {"accel": accel.normalized().x, "fire": false}
	ws.send_data(JSON.print(data))

func connect_ws():
	ws.connect_ws("ws://" + $Connection/Control/VBoxContainer/TextEdit.text + ":9080")

func _on_ConnectBtn_pressed():
	print("Connecting..")
	connect_ws()

func _on_FireBtn_pressed():
	var data = {"accel": 0.0, "fire": true}
	ws.send_data(JSON.print(data))

func _on_WSClient_connected(to_url):
	$Connection.visible = false
	$MarginContainer/HBoxContainer/ServerIP.text = to_url
	$MarginContainer/HBoxContainer/Status.text = "CONNECTED"

func _on_WSClient_disconnected():
	$Connection.visible = true
	$MarginContainer/HBoxContainer/ServerIP.text = ""
	$MarginContainer/HBoxContainer/Status.text = "DISCONNECTED"



