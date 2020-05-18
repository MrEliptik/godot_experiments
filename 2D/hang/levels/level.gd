extends Node2D

export var hooks = -1

enum COLORS {
	WALL_NORMAL,
	WALL_DEAD,
	BACKGROUND_NORMAL,
	BACKGROUND_DEAD,
	GOAL_NORMAL
}

var level_colors = {
	COLORS.WALL_NORMAL: Color('202020'),
	COLORS.WALL_DEAD: Color('c43535'),
	COLORS.BACKGROUND_NORMAL: Color('01131b'),
	COLORS.BACKGROUND_DEAD: Color('ffffff'),
	COLORS.GOAL_NORMAL: Color('50cd80')
}

onready var wall = $StaticBody2D/Line2D
onready var background = $Background
onready var goal = $Goal/Sprite
onready var obstacles = $Obstacles
onready var moving_walls = $Walls

# Called when the node enters the scene tree for the first time.
func _ready():
	var points = wall.get_points()
	background.polygon = points
	change_wall_color(COLORS.WALL_NORMAL)
	change_background_color(COLORS.BACKGROUND_NORMAL)
	change_goal_color(COLORS.GOAL_NORMAL)
	
func reset():
	change_wall_color(COLORS.WALL_NORMAL)
	change_background_color(COLORS.BACKGROUND_NORMAL)
	change_goal_color(COLORS.GOAL_NORMAL)
	invert_background(true)
	if obstacles.get_child_count() > 0:
		for obstacle in obstacles.get_children():
			obstacle.reset()
	if moving_walls.get_child_count() > 0:
		for wall in moving_walls.get_children():
			wall.reset()

func change_wall_color(color):
	wall.default_color = level_colors[color]
	
func invert_background(val):
	background.invert_enable = val	
	
func change_background_color(color):
	background.color = level_colors[color]
	
func change_goal_color(color):
	goal.texture.gradient.set_color(0, level_colors[color])
	
func _on_StartingArea_body_entered(body):
	if body.name == "Player":
		$Walls/MovingWall.moving = true
