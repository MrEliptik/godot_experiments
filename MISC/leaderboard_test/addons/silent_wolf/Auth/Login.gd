extends TextureRect

const SWLogger = preload("../utils/SWLogger.gd")

func _ready():
	#var auth_node = get_tree().get_root().get_node("res://addons/silent_wolf/Auth/Auth")
	SilentWolf.Auth.connect("sw_login_succeeded", self, "_on_login_succeeded")
	SilentWolf.Auth.connect("sw_login_failed", self, "_on_login_failed")

func _on_LoginButton_pressed():
	var username = $"FormContainer/UsernameContainer/Username".text
	var password = $"FormContainer/PasswordContainer/Password".text
	var remember_me = $"FormContainer/RememberMeCheckBox".is_pressed()
	SWLogger.debug("Login form submitted, remember_me: " + str(remember_me))
	SilentWolf.Auth.login_player(username, password, remember_me)
	show_processing_label()
	
func _on_login_succeeded():
	var scene_name = SilentWolf.auth_config.redirect_to_scene
	SWLogger.info("logged in as: " + str(SilentWolf.Auth.logged_in_player))
	get_tree().change_scene(scene_name)
	
func _on_login_failed(error):
	hide_processing_label()
	SWLogger.info("log in failed: " + str(error))
	$"FormContainer/ErrorMessage".text = error
	$"FormContainer/ErrorMessage".show()

func _on_BackButton_pressed():
	get_tree().change_scene(SilentWolf.auth_config.redirect_to_scene)
	
func show_processing_label():
	$"FormContainer/ProcessingLabel".show()
	$"FormContainer/ProcessingLabel".show()
	
func hide_processing_label():
	$"FormContainer/ProcessingLabel".hide()


func _on_LinkButton_pressed():
	get_tree().change_scene(SilentWolf.auth_config.reset_password_scene)
