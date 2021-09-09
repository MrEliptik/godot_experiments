extends TextureRect

var player_name = null
var login_scene = "res://addons/silent_wolf/Auth/Login.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$"RequestFormContainer/ProcessingLabel".hide()
	$"PwdResetFormContainer/ProcessingLabel".hide()
	$"PasswordChangedContainer".hide()
	$"PwdResetFormContainer".hide()
	$"RequestFormContainer".show()
	SilentWolf.Auth.connect("sw_request_password_reset_succeeded", self, "_on_send_code_succeeded")
	SilentWolf.Auth.connect("sw_request_password_reset_failed", self, "_on_send_code_failed")
	SilentWolf.Auth.connect("sw_reset_password_succeeded", self, "_on_reset_succeeded")
	SilentWolf.Auth.connect("sw_reset_password_failed", self, "_on_reset_failed")
	if "login_scene" in SilentWolf.Auth:
		login_scene = SilentWolf.Auth.login_scene

func _on_BackButton_pressed():
	get_tree().change_scene(login_scene)


func _on_PlayerNameSubmitButton_pressed():
	player_name = $"RequestFormContainer/FormContainer/FormInputFields/PlayerName".text
	SilentWolf.Auth.request_player_password_reset(player_name)
	$"RequestFormContainer/ProcessingLabel".show()


func _on_send_code_succeeded():
	$"RequestFormContainer/ProcessingLabel".hide()
	$"RequestFormContainer".hide()
	$"PwdResetFormContainer".show()


func _on_send_code_failed(error):
	$"RequestFormContainer/ProcessingLabel".hide()
	$"RequestFormContainer/ErrorMessage".text = "Could not send confirmation code. " + str(error)
	$"RequestFormContainer/ErrorMessage".show()


func _on_NewPasswordSubmitButton_pressed():
	var code = $"PwdResetFormContainer/FormContainer/FormInputFields/Code".text
	var password = $"PwdResetFormContainer/FormContainer/FormInputFields/Password".text
	var confirm_password = $"PwdResetFormContainer/FormContainer/FormInputFields/ConfirmPassword".text
	SilentWolf.Auth.reset_player_password(player_name, code, password, confirm_password)
	$"PwdResetFormContainer/ProcessingLabel".show()


func _on_reset_succeeded():
	$"PwdResetFormContainer/ProcessingLabel".hide()
	$"PwdResetFormContainer".hide()
	$"PasswordChangedContainer".show()


func _on_reset_failed(error):
	$"PwdResetFormContainer/ProcessingLabel".hide()
	$"PwdResetFormContainer/ErrorMessage".text = "Could not reset password. " + str(error)
	$"PwdResetFormContainer/ErrorMessage".show()


func _on_CloseButton_pressed():
	get_tree().change_scene(login_scene)
