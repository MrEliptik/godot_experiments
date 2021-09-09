extends "res://OQ_Toolkit/OQ_ARVRController/scripts/Feature_ControllerModel_Left_Reactive.gd"

#sets references to button models
#meant to be overriden for other controller
func set_buttons():
	controller = vr.rightController
	select = $OculusQuestTouchController_Right_Reactive/r_controller_Home
	button1 = $OculusQuestTouchController_Right_Reactive/r_controller_A
	button2 = $OculusQuestTouchController_Right_Reactive/r_controller_B
	grip = $OculusQuestTouchController_Right_Reactive/r_controller_Grip
	trigger = $OculusQuestTouchController_Right_Reactive/r_controller_Trigger
	joy = $OculusQuestTouchController_Right_Reactive/r_controller_Joy
