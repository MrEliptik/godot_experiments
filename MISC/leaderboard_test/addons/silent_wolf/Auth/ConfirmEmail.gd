extends TextureRect


const SWLogger = preload("../utils/SWLogger.gd")


func _ready():
	SilentWolf.Auth.connect("sw_email_verif_succeeded", self, "_on_confirmation_succeeded")
	SilentWolf.Auth.connect("sw_email_verif_failed", self, "_on_confirmation_failed")
	SilentWolf.Auth.connect("sw_resend_conf_code_succeeded", self, "_on_resend_code_succeeded")
	SilentWolf.Auth.connect("sw_resend_conf_code_failed", self, "_on_resend_code_failed")


func _on_confirmation_succeeded():
	SWLogger.info("email verification succeeded: " + str(SilentWolf.Auth.logged_in_player))
	# redirect to configured scene (user is logged in after registration)
	var scene_name = SilentWolf.auth_config.redirect_to_scene
	get_tree().change_scene(scene_name)


func _on_confirmation_failed(error):
	hide_processing_label()
	SWLogger.info("email verification failed: " + str(error))
	$"FormContainer/ErrorMessage".text = error
	$"FormContainer/ErrorMessage".show()


func _on_resend_code_succeeded():
	SWLogger.info("Code resend succeeded for player: " + str(SilentWolf.Auth.tmp_username))
	$"FormContainer/ErrorMessage".text = "Confirmation code was resent to your email address. Please check your inbox (and your spam)."
	$"FormContainer/ErrorMessage".show()


func _on_resend_code_failed():
	SWLogger.info("Code resend failed for player: " + str(SilentWolf.Auth.tmp_username))
	$"FormContainer/ErrorMessage".text = "Confirmation code could not be resent"
	$"FormContainer/ErrorMessage".show()


func show_processing_label():
	$"FormContainer/ProcessingLabel".show()


func hide_processing_label():
	$"FormContainer/ProcessingLabel".hide()


func _on_ConfirmButton_pressed():
	var username = SilentWolf.Auth.tmp_username
	var code = $"FormContainer/CodeContainer/VerifCode".text
	SWLogger.debug("Email verification form submitted, code: " + str(code))
	SilentWolf.Auth.verify_email(username, code)
	show_processing_label()


func _on_ResendConfCodeButton_pressed():
	var username = SilentWolf.Auth.tmp_username
	SWLogger.debug("Requesting confirmation code resend")
	SilentWolf.Auth.resend_conf_code(username)
	show_processing_label()
