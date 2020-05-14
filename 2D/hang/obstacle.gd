extends Node2D

onready var wall = $StaticBody2D/Line2D
onready var background = $Polygon2D

enum COLORS {
	WALL_NORMAL,
	WALL_DEAD,
	BACKGROUND_NORMAL,
	BACKGROUND_DEAD
}

var obstacles_colors = {
	COLORS.WALL_NORMAL: Color('202020'),
	COLORS.WALL_DEAD: Color('c43535'),
	COLORS.BACKGROUND_NORMAL: Color('040404'),
	COLORS.BACKGROUND_DEAD: Color('ffffff')
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var points = wall.get_points()
	background.polygon = points
	change_wall_color(COLORS.WALL_NORMAL)
	change_background_color(COLORS.BACKGROUND_NORMAL)
	
func reset():
	change_wall_color(COLORS.WALL_NORMAL)
	change_background_color(COLORS.BACKGROUND_NORMAL)

func change_wall_color(color):
	wall.default_color = obstacles_colors[color]
	
func invert_background(val):
	background.invert_enable = val	
	
func change_background_color(color):
	background.color = obstacles_colors[color]
