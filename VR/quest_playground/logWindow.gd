extends Spatial

onready var label = $Viewport/ScrollContainer/Label

enum LEVELS {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}
var level_color = {
	LEVELS.DEBUG: Color('ededed'),
	LEVELS.INFO: Color('1032a3'),
	LEVELS.WARNING: Color('a36610'),
	LEVELS.ERROR: Color('a31010'),
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _log(msg, level=LEVELS.DEBUG):
	var sb = $Viewport/ScrollContainer.get_v_scrollbar();
	sb.value = sb.max_value;
	label.add_color_override("font_color", level_color[level])
	label.text += '\n>>' + msg
	sb = $Viewport/ScrollContainer.get_v_scrollbar();
	sb.value = sb.max_value; # autoscroll to the last line of the log buffer
	
func clear():
	label.text = ""	
