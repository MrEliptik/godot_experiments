extends Spatial

onready var label = $OQ_UILabel;

func _ready():
	label.set_label_text("IPD: %.1fmm" % 60.0);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	if (is_visible_in_tree() && vr.ovrUtilities):
		label.set_label_text("IPD: %.1fmm" % (vr.get_ipd() * 1000.0));
