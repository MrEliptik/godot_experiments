extends Spatial

onready var label_gesture = $Label_SimpleGesture;

func _process(_dt):
	
	if (!vr.rightController.is_hand):
		label_gesture.set_label_text("Please enable hand tracking for gesture detection!");
	else:
		var hand = vr.rightController.get_hand_model();
		if (hand):
			label_gesture.set_label_text("Right Hand Gesture is: " + hand.detect_simple_gesture());


func _ready():
	pass # Replace with function body.

