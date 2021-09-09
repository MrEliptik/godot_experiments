extends Spatial

onready var locomotion_stick = $OQ_ARVROrigin/Locomotion_Stick;

# Some introductory text shown on an info label
var info_text = """Welcome to the Godot Oculus Quest Toolkit Demo!

This is the UI test room.
 - Press Trigger/Pinch to select menu items.
 - Press Y to toggle the hand UI test.
 - Behind you is a big console window.

You can press the menu button (or left pinch middle)
to return here.
"""


func setup_movement_options_ui():
	var movement_options_root = $OQ_UI2DCanvas_MovementOptions;
	var move_speed_spinbox : SpinBox = movement_options_root.find_node("MoveSpeedSpinBox", true, false);
	var rotate_speed_spinbox : SpinBox = movement_options_root.find_node("RotateSpeedSpinBox", true, false);
	var rotation_optionbutton : OptionButton = movement_options_root.find_node("RotationOptionButton", true, false);
	var click_turn_angle_spinbox : SpinBox = movement_options_root.find_node("ClickTurnAngleSpinBox", true, false);

	move_speed_spinbox.value = locomotion_stick.move_speed;
	rotate_speed_spinbox.value = locomotion_stick.smooth_turn_speed;
	click_turn_angle_spinbox.value = locomotion_stick.click_turn_angle;
	
	rotation_optionbutton.add_item("Click");
	rotation_optionbutton.add_item("Smooth");
	
	
func _on_text_enter(text):
	var t = $OQ_UI2DKeyboard/TestTextInputLabel.get_label_text() + "\n" + text;
	$OQ_UI2DKeyboard/TestTextInputLabel.set_label_text(t);

func _ready():
	setup_movement_options_ui();
	$InfoLabel.set_label_text(info_text);
	
	$OQ_UI2DKeyboard.connect("text_input_enter", self, "_on_text_enter");
	

func _on_MoveSpeedSpinBox_value_changed(value):
	locomotion_stick.move_speed = value;
	vr.log_info("Changed move speed to %f" % value);


func _on_RotationOptionButton_item_selected(id):
	if (id == 0): locomotion_stick.turn_type = locomotion_stick.TurnType.CLICK;
	if (id == 1): locomotion_stick.turn_type = locomotion_stick.TurnType.SMOOTH;
	vr.log_info("Changed turn type to %s" % locomotion_stick.turn_type);

func _on_RotateSpeedSpinBox_value_changed(value):
	locomotion_stick.smooth_turn_speed = value;
	vr.log_info("Changed smooth turn speed to %s" % locomotion_stick.smooth_turn_speed);
	
func _on_ClickTurnAngleSpinBox_value_changed(value):
	locomotion_stick.click_turn_angle = value;
	vr.log_info("Changed click turn angle to %s" % locomotion_stick.click_turn_angle);


func _on_ButtonPhysics_pressed():
	vr.switch_scene("res://demo_scenes/PhysicsScene.tscn");


func _on_ButtonClimbing_pressed():
	vr.switch_scene("res://demo_scenes/ClimbingScene.tscn");


func _on_ButtonWalkInPlace_pressed():
	vr.switch_scene("res://demo_scenes/WalkInPlaceDemoScene.tscn");


func _on_HandTracking_pressed():
	vr.switch_scene("res://demo_scenes/HandTrackingDemoScene.tscn");


func _on_PlayerCollision_pressed():
	vr.switch_scene("res://demo_scenes/PlayerCollisionDemoScene.tscn");
