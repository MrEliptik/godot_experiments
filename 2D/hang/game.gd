extends Node2D

onready var player = $Player
onready var joints = $Joints
onready var winscreen = $CanvasLayer/WinScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("anchor", self, "on_anchor")
	player.connect("free", self, "on_free")

func on_anchor(point, collider):
	# First, remove the joint
	if joints.get_child_count() > 0:
		joints.remove_child(joints.get_child(0))
	
	# Add a joint
	var joint = PinJoint2D.new()
	# Joint need path to node
	joint.node_a = collider.get_path()
	joint.node_b = player.get_path()
	joint.global_position = point
	joints.add_child(joint)
	
func on_free():
	if joints.get_child_count() > 0:
		joints.remove_child(joints.get_child(0))

func _on_Goal_body_entered(body):
	player.visible = false
	winscreen.visible = true
