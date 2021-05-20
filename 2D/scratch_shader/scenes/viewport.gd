extends Viewport

func _ready():
	# Don't clear to keep the previous drawing
	render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
