extends Node2D

var pressed = false

onready var scratched_text = ImageTexture.new()
onready var scratched_im = Image.new()
var text_rect = null

var positions = []

func _ready():
	# To avoid mouse coordinates going under or over window size
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	get_viewport().render_target_clear_mode = Viewport.CLEAR_MODE_NEVER

func _input(event):	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			pressed = event.is_pressed()
	
func _process(delta):
	if pressed:
		positions.append(get_local_mouse_position())
		$Viewport/Node2D.draw_at(positions)
	
	yield(VisualServer, "frame_post_draw")
	var img = $Viewport.get_texture().get_data()
	
	if Input.is_action_just_pressed("ui_accept"):
		img.flip_y()
		img.save_png("test_main.png")

	var tex = ImageTexture.new()
	tex.create_from_image(img)

	$TextureRect2.texture = tex
	$ScratchTexture.material.set_shader_param("scratch_texture", tex)
