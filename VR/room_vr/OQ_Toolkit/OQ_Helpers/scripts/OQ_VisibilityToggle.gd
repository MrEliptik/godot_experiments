# Simple visibility toggle on button press
extends Spatial

export(vr.BUTTON) var toggle_button = vr.BUTTON.Y;

# we have this separate to see it in the editor but
# have it hidden on actual start
export var invisible_on_start = false;


var cycle_through_children = false; #Not yet implemented

func set_visibility_and_process(v):
	visible = v;


func _process(_dt):
	if (vr.button_just_pressed(toggle_button)):
		if (!cycle_through_children):
			set_visibility_and_process(!visible);
		else:
			print("TODO: non global visibility toggle not yet implemented");

func _ready():
	if (invisible_on_start): set_visibility_and_process(false);
