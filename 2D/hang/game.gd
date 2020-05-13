extends Node2D

onready var player = $Player
onready var joints = $Joints
onready var winscreen = $CanvasLayer/WinScreen
onready var levels = $Levels
onready var player_pos = $PlayerPos.global_position
onready var camera = $Camera2D
onready var player_camera = $Player/Camera2D

var curr_level_nb = 0
var curr_level

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level("res://levels/level_" +str(curr_level_nb)+ ".tscn")
	player.connect("anchor", self, "on_anchor")
	player.connect("free", self, "on_free")
	player.connect("die", self, "on_die")
	#levels.get_child(0).get_node("Goal").connect("body_entered", self, "_on_Goal_body_entered")

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
	# Important for the player to be able
	# to collide with the node_a
	joint.disable_collision = false
	joints.add_child(joint)
	
func load_next_level():
	curr_level_nb += 1
	print("level_"+str(curr_level_nb))
	var lvl = load("res://levels/level_" +str(curr_level_nb)+ ".tscn")
	if lvl == null: return
	# Remove curr level
	if levels.get_child_count() > 0:
		var to_remove = levels.get_child(0)
		levels.call_deferred("remove_child", to_remove)
	# Add next level
	var level = lvl.instance()
	level.connect("ready", self, "on_level_ready")
	levels.call_deferred("add_child", level)

func load_level(level_str):
	var lvl = load(level_str)
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
	if player.dead: return
	print(body.name)
	$WinSound.play()
	player.contact_monitor = false
	# Reset player first to avoid colliding with next level
	player.reset(player_pos)
#	player.visible = false
#	winscreen.visible = true
	load_next_level()
	
	if joints.get_child_count() > 0:
		joints.remove_child(joints.get_child(0))
	
func on_level_ready():
	curr_level = levels.get_child(0)
	# Connect after resetting position to avoid re-triggering
	curr_level.get_node("Goal").connect("body_entered", self, "_on_Goal_body_entered")

func on_die():
	# Switch wall color
	if curr_level.has_method("change_wall_color"):
		curr_level.change_wall_color(curr_level.COLORS.WALL_DEAD)
	# Switch bg color
	if curr_level.has_method("change_background_color"):
		curr_level.change_background_color(curr_level.COLORS.BACKGROUND_DEAD)
	# Invert bg
	if curr_level.has_method("invert_background"):
		curr_level.invert_background(false)
		
	# Switch goal color
	if curr_level.has_method("change_goal_color"):
		curr_level.change_goal_color(curr_level.COLORS.WALL_DEAD)
	
	# Switch to player's camera
	camera.current = false
	player_camera.current = true
	player_camera.zoom(0.7, 0.7, 0.5)
	player_camera.shake(0.5, 15, 10)
	$DeathTimer.start()

func _on_DeathTimer_timeout():
	get_tree().reload_current_scene()
