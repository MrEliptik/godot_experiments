extends "res://OQ_Toolkit/OQ_ARVRController/scripts/Feature_ControllerModel.gd"

#constants
const MENU_PRESSED = -.0005
const X_PRESSED = -.002
const Y_PRESSED = -.002
const GRIP_PRESSED = -.0035
const TRIGGER_PRESSED = 25 #degrees
const JOY_PRESSED = 20 #degrees

#instance variables
var controller
var select
var button1
var button2
var grip
var trigger
var joy


func _ready():
	set_buttons()

#sets references to button models
#meant to be overriden for other controller
func set_buttons():
	controller = vr.leftController
	select = $OculusQuestTouchController_Left_Reactive/l_controller_Menu
	button1 = $OculusQuestTouchController_Left_Reactive/l_controller_X
	button2 = $OculusQuestTouchController_Left_Reactive/l_controller_Y
	grip = $OculusQuestTouchController_Left_Reactive/l_controller_Grip
	trigger = $OculusQuestTouchController_Left_Reactive/l_controller_Trigger
	joy = $OculusQuestTouchController_Left_Reactive/l_controller_Joy

func _process(_delta):
	update_buttons();

#updates the positions of the buttons based on what is currently pressed
# ideally the digital buttons would be updated on a signal rather than every delta
# but in the interest of not modifying existing architecture it is done this way
func update_buttons():
	if controller and button1:
		select.transform.origin.y = MENU_PRESSED * controller.is_button_pressed(vr.CONTROLLER_BUTTON.ENTER)
		button1.transform.origin.y = X_PRESSED * controller.is_button_pressed(vr.CONTROLLER_BUTTON.XA)
		button2.transform.origin.y   = Y_PRESSED * controller.is_button_pressed(vr.CONTROLLER_BUTTON.YB)
		grip.transform.origin.x = GRIP_PRESSED * ((controller.get_joystick_axis(vr.CONTROLLER_AXIS.GRIP_TRIGGER) + 1) / 2)
		trigger.rotation_degrees.x = TRIGGER_PRESSED * ((controller.get_joystick_axis(vr.CONTROLLER_AXIS.INDEX_TRIGGER) + 1)/2)
		joy.rotation_degrees.x = JOY_PRESSED * controller.get_joystick_axis(vr.CONTROLLER_AXIS.JOYSTICK_Y)
		joy.rotation_degrees.z = JOY_PRESSED * controller.get_joystick_axis(vr.CONTROLLER_AXIS.JOYSTICK_X)
		#flip for right
		if controller == vr.rightController:
			grip.transform.origin.x *= -1
			trigger.rotation_degrees.x *= -1
			joy.rotation_degrees.x *= -1
			joy.rotation_degrees.z *= -1
