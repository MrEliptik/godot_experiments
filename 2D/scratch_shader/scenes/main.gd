extends Node2D

var pressed = false

func _ready():
	# To avoid mouse coordinates going under or over window size
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _input(event):	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			pressed = event.is_pressed()
	
func _process(delta):
	if pressed:
		$Viewport/Drawing.draw_at(get_local_mouse_position())
	
	yield(VisualServer, "frame_post_draw")
	var img = $Viewport.get_texture().get_data()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)

	$ScratchTexture.material.set_shader_param("scratch_texture", tex)
