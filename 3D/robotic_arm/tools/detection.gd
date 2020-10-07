const Blob = preload("res://tools/blob.gd")
const HSV = preload("res://tools/hsv.gd")

func binarizeWithColor(args):
	var im = args[0]
	var color = args[1]
	var tolerance = args[2]
	
	var binarized_im = Image.new()
	binarized_im.copy_from(im)
	
	# Lock images before reading and setting
	im.lock()
	binarized_im.lock()
	
	for i in range(im.get_width()):
		for j in range(im.get_height()):
			var pixel = im.get_pixel(i,j)
			var pixel_hsv = HSV.RGB_to_HSV(pixel)
			var dist = pixel_hsv.distance_to(color)
			#print(dist)
			if dist < tolerance:
				binarized_im.set_pixel(i, j, Color(1.0,1.0,1.0))
			else:
				binarized_im.set_pixel(i, j, Color(0.0,0.0,0.0))
				
	im.unlock()
	binarized_im.unlock()
	var binarized_texture = ImageTexture.new()
	binarized_texture.create_from_image(binarized_im)
	
	return binarized_texture
	
func detectColorBlob(im, color):	
	if !im: return
	
	# Lock image before reading
	im.lock()
	var binarized_im = Image.new()
	binarized_im.copy_from(im)
	im.unlock()

	var blobs = []
	
	var h = binarized_im.get_height()
	var w = binarized_im.get_width()

	binarized_im.lock()
	
	for i in range(h):
		for j in range(w):
			# Not white pixel, we don't care
			var pixel = binarized_im.get_pixel(i, j)
			#print(pixel)
			if pixel == color:	
				var found = false
				# Loop through existing blobs
				for blob in blobs:
					if blob.is_near(i, j):
						blob.add(i, j)
						found = true
						break
				if !found:
					var b = Blob.new()
					b.blob(i, j)
					blobs.append(b)
	# Unlock when finished
	binarized_im.unlock()
	return blobs
