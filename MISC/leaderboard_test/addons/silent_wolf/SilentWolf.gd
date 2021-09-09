extends Node

const version = "0.6.6"

onready var Auth = Node.new()
onready var Scores = Node.new()
onready var Players = Node.new()

#
# SILENTWOLF CONFIG: THE CONFIG VARIABLES BELOW WILL BE OVERRIDED THE 
# NEXT TIME YOU UPDATE YOUR PLUGIN!
#
# As a best practice, use SilentWolf.configure from your game's
# code instead to set the SilentWolf configuration.
#
# See https://silentwolf.com for more details
#
var config = {
	"api_key": "FmKF4gtm0Z2RbUAEU62kZ2OZoYLj4PYOURAPIKEY",
	"game_id": "YOURGAMEID",
	"game_version": "0.0.0",
	"log_level": 1
}

var scores_config = {
	"open_scene_on_close": "res://scenes/Splash.tscn"
}

var auth_config = {
	"redirect_to_scene": "res://scenes/Splash.tscn",
	"login_scene": "res://addons/silent_wolf/Auth/Login.tscn",
	"email_confirmation_scene": "res://addons/silent_wolf/Auth/ConfirmEmail.tscn",
	"reset_password_scene": "res://addons/silent_wolf/Auth/ResetPassword.tscn",
	"session_duration_seconds": 0,
	"saved_session_expiration_days": 30
}

var auth_script = load("res://addons/silent_wolf/Auth/Auth.gd")
var scores_script = load("res://addons/silent_wolf/Scores/Scores.gd")
var players_script = load("res://addons/silent_wolf/Players/Players.gd")

func _init():
	print("SW Init timestamp: " + str(OS.get_time()))

func _ready():
	print("SW ready start timestamp: " + str(OS.get_time()))
	Auth.set_script(auth_script)
	#Auth.set_script(preload("res://addons/silent_wolf/Auth/Auth.gd"))
	add_child(Auth)
	Scores.set_script(scores_script)
	#Scores.set_script(preload("res://addons/silent_wolf/Scores/Scores.gd"))
	add_child(Scores)
	Players.set_script(players_script)
	#Players.set_script(preload("res://addons/silent_wolf/Players/Players.gd"))
	add_child(Players)
	print("SW ready end timestamp: " + str(OS.get_time()))

func configure(json_config):
	config = json_config

func configure_api_key(api_key):
	config.apiKey = api_key

func configure_game_id(game_id):
	config.game_id = game_id

func configure_game_version(game_version):
	config.game_version = game_version

##################################################################
# Log levels:
# 0 - error (only log errors)
# 1 - info (log errors and the main actions taken by the SilentWolf plugin) - default setting
# 2 - debug (detailed logs, including the above and much more, to be used when investigating a problem). This shouldn't be the default setting in production.
##################################################################
func configure_log_level(log_level):
	config.log_level = log_level

func configure_scores(json_scores_config):
	scores_config = json_scores_config

func configure_scores_open_scene_on_close(scene):
	scores_config.open_scene_on_close = scene
	
func configure_auth(json_auth_config):
	auth_config = json_auth_config

func configure_auth_redirect_to_scene(scene):
	auth_config.open_scene_on_close = scene
	
func configure_auth_session_duration(duration):
	auth_config.session_duration = duration
	
func free_request(weak_ref, object):
	if (weak_ref.get_ref()):
		object.queue_free()
