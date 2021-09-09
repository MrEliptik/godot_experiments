extends Node

const CommonErrors = preload("../common/CommonErrors.gd")
const SWLogger = preload("../utils/SWLogger.gd")

signal sw_player_data_received
signal sw_player_data_posted
signal sw_player_data_removed

var GetPlayerData = null
var PushPlayerData = null
var RemovePlayerData = null

# wekrefs
var wrGetPlayerData = null
var wrPushPlayerData = null
var wrRemovePlayerData = null

var player_name = null
var player_data = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_player_data(new_player_data):
	player_data = new_player_data

func clear_player_data():
	player_name = null
	player_data = null
	
func get_stats():
	var stats = null
	if player_data:
		stats = {
			"strength": player_data.strength,
			"speed": player_data.speed,
			"reflexes": player_data.reflexes,
			"max_health": player_data.max_health,
			"career": player_data.career
		}
	return stats
	
func get_inventory():
	var inventory = null
	if player_data:
		inventory = {
			"weapons": player_data.weapons,
			"gold": player_data.gold
		}
	return inventory

func get_player_data(player_name):
	GetPlayerData = HTTPRequest.new()
	wrGetPlayerData = weakref(GetPlayerData)
	if OS.get_name() != "HTML5":
		GetPlayerData.set_use_threads(true)
	get_tree().get_root().add_child(GetPlayerData)
	GetPlayerData.connect("request_completed", self, "_on_GetPlayerData_request_completed")
	SWLogger.info("Calling SilentWolf to get player data")
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var api_key = SilentWolf.config.api_key
	var headers = ["Content-Type: application/json", "x-api-key: " + api_key]
	GetPlayerData.request("https://api.silentwolf.com/get_player_data/" + game_id + "/" + player_name, headers, true, HTTPClient.METHOD_GET)
	return self
	
func post_player_data(player_name, player_data, overwrite=true):
	PushPlayerData = HTTPRequest.new()
	wrPushPlayerData = weakref(PushPlayerData)
	if OS.get_name() != "HTML5":
		PushPlayerData.set_use_threads(true)
	get_tree().get_root().add_child(PushPlayerData)
	PushPlayerData.connect("request_completed", self, "_on_PushPlayerData_request_completed")
	SWLogger.info("Calling SilentWolf to post player data")
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var api_key = SilentWolf.config.api_key
	var headers = ["Content-Type: application/json", "x-api-key: " + api_key]
	var payload = { "game_id": game_id, "game_version": game_version, "player_name": player_name, "player_data": player_data, "overwrite": overwrite }
	var query = JSON.print(payload)
	PushPlayerData.request("https://api.silentwolf.com/push_player_data", headers, true, HTTPClient.METHOD_POST, query)
	return self
	
func delete_player_weapons(player_name):
	var weapons = { "Weapons": [] }
	delete_player_data(player_name, weapons)
	
func remove_player_money(player_name):
	var money = { "Money": 0 }
	delete_player_data(player_name, money)
	
func delete_player_items(player_name, item_name):
	var item = { item_name: "" }
	delete_player_data(player_name, item)
	
func delete_all_player_data(player_name):
	delete_player_data(player_name, "")
	
func delete_player_data(player_name, player_data):
	RemovePlayerData = HTTPRequest.new()
	wrRemovePlayerData = weakref(RemovePlayerData)
	if OS.get_name() != "HTML5":
		RemovePlayerData.set_use_threads(true)
	get_tree().get_root().add_child(RemovePlayerData)
	RemovePlayerData.connect("request_completed", self, "_on_RemovePlayerData_request_completed")
	SWLogger.info("Calling SilentWolf to remove player data")
	var game_id = SilentWolf.config.game_id
	var api_key = SilentWolf.config.api_key
	var headers = ["Content-Type: application/json", "x-api-key: " + api_key]
	var payload = { "game_id": game_id, "player_name": player_name, "player_data": player_data }
	var query = JSON.print(payload)
	RemovePlayerData.request("https://api.silentwolf.com/remove_player_data", headers, true, HTTPClient.METHOD_POST, query)
	return self
	
func _on_GetPlayerData_request_completed(result, response_code, headers, body):
	SWLogger.info("GetPlayerData request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	#print("client status: " + str(GetPlayerData.get_http_client_status()))
	if is_instance_valid(GetPlayerData): 
		SilentWolf.free_request(wrGetPlayerData, GetPlayerData)
		#GetPlayerData.queue_free()
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/playerdata")
		else:
			SWLogger.info("SilentWolf get player data success")
			player_name = response.player_name
			player_data = response.player_data
			SWLogger.debug("Request completed: Player data: " + str(player_data))
			emit_signal("sw_player_data_received", player_name, player_data)
		
func _on_PushPlayerData_request_completed(result, response_code, headers, body):
	SWLogger.info("PushPlayerData request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	if is_instance_valid(PushPlayerData): 
		#PushPlayerData.queue_free()
		SilentWolf.free_request(wrPushPlayerData, PushPlayerData)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/playerdata")
		else:
			SWLogger.info("SilentWolf post player data score success: " + str(response_code))
			var player_name = response.player_name
			emit_signal("sw_player_data_posted", player_name)
		
func _on_RemovePlayerData_request_completed(result, response_code, headers, body):
	SWLogger.info("RemovePlayerData request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	if is_instance_valid(RemovePlayerData): 
		RemovePlayerData.queue_free()
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/playerdata")
		else:
			SWLogger.info("SilentWolf post player data score success: " + str(response_code))
			var player_name = response.player_name
			# return player_data after (maybe partial) removal
			var player_data = response.player_data
			emit_signal("sw_player_data_removed", player_name, player_data)
