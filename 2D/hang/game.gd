extends Node2D

onready var player = $Player
onready var joints = $Joints
onready var winscreen = $CanvasLayer/WinScreen
onready var levels = $Levels
onready var player_pos = $PlayerPos.global_position

var curr_level_nb = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("anchor", self, "on_anchor")
	player.connect("free", self, "on_free")
	levels.get_child(0).get_node("Goal").connect("body_entered", self, "_on_Goal_body_entered")

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
	
func load_next_level():
	curr_level_nb += 1
	print("level_"+str(curr_level_nb))
	var lvl = load("res://levels/level_" +str(curr_level_nb)+ ".tscn")
	# Remove curr level
	if levels.get_child_count() > 0:
		var to_remove = levels.get_child(0)
		levels.call_deferred("remove_child", to_remove)
	# Add next level
	var level = lvl.instance()
	level.connect("ready", self, "on_level_ready")
	levels.call_deferred("add_child", level)
	
func reset_player():
	player.global_position = player_pos
	
func on_free():
	if joints.get_child_count() > 0:
		joints.remove_child(joints.get_child(0))

func _on_Goal_body_entered(body):
	print(body.name)
	player.contact_monitor = false
#	player.visible = false
#	winscreen.visible = true
	load_next_level()
	
	if joints.get_child_count() > 0:
		joints.remove_child(joints.get_child(0))
	
func on_level_ready():
	# Connect after resetting position to avoid re-triggering
	levels.get_child(0).get_node("Goal").connect("body_entered", self, "_on_Goal_body_entered")
	player.reset(player_pos)

func _on_Timer_timeout():
	pass # Replace with function body.
