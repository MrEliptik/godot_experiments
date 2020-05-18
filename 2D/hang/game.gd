extends Node2D

onready var player = $Player
onready var joints = $Joints
onready var winscreen = $CanvasLayer/WinScreen
onready var levels = $Levels
onready var camera = $Camera2D
onready var player_camera = $Player/Camera2D
onready var hud = $CanvasLayer/HUD

const player_scene = preload("res://player.tscn")

var curr_level_nb = 10
var curr_level

var level_hooks = -1
var player_hooks = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level("res://levels/level_" +str(curr_level_nb)+ ".tscn")
	player.connect("anchor", self, "on_anchor")
	player.connect("free", self, "on_free")
	player.connect("die", self, "on_die")
	player.connect("swipe", self, "on_swipe")

func on_anchor(point, collider):
	# First, remove the joint
	if joints.get_child_count() > 0:
		joints.remove_child(joints.get_child(0))
		
	# If level_hooks is != -1, we use a hook
	if level_hooks != -1:
		if player_hooks > 0:
			player_hooks -= 1
			$CanvasLayer/HUD.set_hooks(player_hooks)
		else: return
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
	
func remove_anchor():
	if joints.get_child_count() > 0:
		joints.remove_child(joints.get_child(0))
	
func load_next_level():
	curr_level_nb += 1
	print("level_"+str(curr_level_nb))
	var lvl = "res://levels/level_" +str(curr_level_nb)+ ".tscn"
	load_level(lvl)

func load_previous_level():
	curr_level_nb -= 1
	print("level_"+str(curr_level_nb))
	var lvl = "res://levels/level_" +str(curr_level_nb)+ ".tscn"
	load_level(lvl)

func load_level(level_str):
	var lvl = load(level_str)
	if lvl == null: return
	# Remove curr level
	if levels.get_child_count() > 0:
		var to_remove = levels.get_child(0)
		levels.call_deferred("remove_child", to_remove)
		call_deferred("remove_child", player)
	# Add next level
	var level = lvl.instance()
	level.connect("ready", self, "on_level_ready")
	levels.call_deferred("add_child", level)
	
func reset_current_level():
	curr_level.reset()
	#player.reset(curr_level.get_node('PlayerPosition'))
	reset_player()
	level_hooks = curr_level.hooks
	player_hooks = level_hooks
	player.hooks = level_hooks

func reset_player():
	# Add player instance to node2D, to place it in space
	player_camera.current = false
	camera.current = true
	if player:
		remove_child(player)
	var p = player_scene.instance()
	p.connect("ready", self, "on_player_node_ready")
	add_child(p)
	
func on_free():
	if joints.get_child_count() > 0:
		joints.remove_child(joints.get_child(0))

func _on_Goal_body_entered(body):
	if player.dead: return
	player.contact_monitor = false
	print(body.name)
	$WinSound.play()
	#player.contact_monitor = false

#	player.visible = false
#	winscreen.visible = true
	load_next_level()
	
	if joints.get_child_count() > 0:
		joints.remove_child(joints.get_child(0))
	
func on_level_ready():
	hud.set_level(curr_level_nb)
	curr_level = levels.get_child(0)
	# Connect after resetting position to avoid re-triggering
	curr_level.get_node("Goal").connect("body_entered", self, "_on_Goal_body_entered")

	reset_player()
	
	level_hooks = curr_level.hooks
	player_hooks = level_hooks
	player.hooks = level_hooks
	$CanvasLayer/HUD.set_hooks(level_hooks)
	
func on_player_node_ready():
	player = $Player
	player_camera = $Player/Camera2D
	player.global_position = curr_level.get_node("PlayerPosition").global_position
	player.connect("anchor", self, "on_anchor")
	player.connect("free", self, "on_free")
	player.connect("die", self, "on_die")
	player.connect("swipe", self, "on_swipe")
	

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
		
	# If level has obstacles, change their colors too
	if curr_level.get_node("Obstacles").get_child_count() > 0:
		for child in curr_level.get_node("Obstacles").get_children():
			child.change_wall_color(child.COLORS.WALL_DEAD)
			child.change_background_color(child.COLORS.BACKGROUND_DEAD)
	
	remove_anchor()
	# Switch to player's camera
	camera.current = false
	player_camera.current = true
	player_camera.zoom(0.7, 0.7, 0.5)
	player_camera.shake(0.5, 15, 10)
	$DeathTimer.start()

func on_swipe(direction):
	if direction == "right":
		load_previous_level()
	elif direction == "left":
		load_next_level()

func _on_DeathTimer_timeout():
	reset_current_level()
