extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	var offset = get_parent().get_node("VBoxContainer2/VBoxContainer4/BinarizedImageShader").rect_global_position
	var blobs = get_parent().get_parent().blobs
	
	var size = get_parent().get_node("VBoxContainer2/VBoxContainer4/BinarizedImageShader").rect_size
	var texture_size = get_parent().get_node("VBoxContainer2/VBoxContainer4/BinarizedImageShader").texture.get_size()
	
	
	if blobs == null: return
	for blob in blobs:
		var offseted_rect = Rect2(offset + blob.rect().position, blob.rect().size)
		draw_rect(offseted_rect, Color(0.0, 1.0, 0.0), false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
