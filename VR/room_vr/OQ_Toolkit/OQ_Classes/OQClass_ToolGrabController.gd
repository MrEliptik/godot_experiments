extends Spatial

class_name OQClass_ToolGrabController

func pose_part(start_grab_pos: Vector3, new_grab_pos: Vector3):
	pass

func hand_slipped():
	get_parent().notify_hand_slipped()

func process_release(part: Spatial):
	pass
