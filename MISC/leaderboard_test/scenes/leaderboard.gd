extends Control

export var api_key: String = ""
export var game_id: String = ""
export var game_version: String = "1.0.0"

func _ready():
	SilentWolf.configure({
		"api_key": api_key,
		"game_id": game_id,
		"game_version": game_version,
		"log_level": 1
	})
