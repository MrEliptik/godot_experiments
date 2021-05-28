extends Node2D

var pressed = false
var positions = []

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
	
	# Loop through all the pixels os the scratch and mask texture
	# basically doing what the shader is doing but sequentally this time.
	if !$ScratchTexture.texture: return
	var scratch_im: Image = $ScratchTexture.texture.get_data()
	img.lock()
	scratch_im.lock()
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var mask_pixel = img.get_pixel(x, y)
			var scratch_pixel = scratch_im.get_pixel(x, y)
			scratch_pixel.a = 1.0 - mask_pixel.r
			scratch_im.set_pixel(x, y, scratch_pixel)
			
	var new_texture = ImageTexture.new()
	new_texture.create_from_image(scratch_im)
	$ScratchTexture.texture = new_texture
	
	img.unlock()
	scratch_im.unlock()
