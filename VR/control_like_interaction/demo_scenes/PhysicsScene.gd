extends Spatial

const info_text = """Physics Demo Room

Right Controller uses GrabType == HingeJoint
Left Controller uses GrabType == Velocity + Reparent Mesh
"""

func _ready():
	$InfoLabel.set_label_text(info_text);

