extends Node2D

onready var player = $Player

var enemy = preload("res://scenes/enemy.tscn")
var started = false

func _ready():
	randomize()

func _process(delta):
	pass

func spawn_enemy():
	var instance = enemy.instance()
	add_child(instance)
	instance.global_position = Vector2(rand_range(64, 1856), -64)

func _on_SpawnTimer_timeout():
	spawn_enemy()

func _on_Area2D_area_entered(area):
	if !area.is_in_group("Enemies"): return
	area.die()

func _on_WebSocketsServer_connected(to_url):
	$CanvasLayer/HUD.set_ip(to_url)
	$CanvasLayer/HUD.set_status("CONNECTED")

func _on_WebSocketsServer_disconnected():
	$CanvasLayer/HUD.set_ip("")
	$CanvasLayer/HUD.set_status("DISCONNECTED")

func _on_WebSocketsServer_new_accel_data(data):
	# Parse data
	var json_res = JSON.parse(data)
	if json_res.error != OK:
		print("ERROR parsing: ", json_res.error)
		print(json_res.error_string)
		return
	if !(json_res.result is Dictionary): return
	player.move(json_res.result["accel"])
	if json_res.result["fire"]:
		if !started:
			$SpawnTimer.start()
			started = true
			$CanvasLayer/HUD.set_started(true)
			return
		player.fire()
