extends TextureRect

export var api_key: String

onready var http_req = $HTTPRequest
onready var image_http_req = $ImageHTTPReq

func _ready():
	request_nasa_image_link()

func request_nasa_image_link():
	var url = "https://api.nasa.gov/planetary/apod?api_key="+api_key
	http_req.request(url)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code != 200: 
		print(response_code, body.get_string_from_utf8())
		return
		
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result["title"])
	print(json.result["explanation"])
	print(json.result["hdurl"])
	
	# Perform the HTTP request. The URL below returns a JPG
	var http_error = image_http_req.request(json.result["url"])
	if http_error != OK:
		print("An error occurred in the HTTP request.")

func _on_ImageHTTPReq_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var image_error = image.load_jpg_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
		
	var tex = ImageTexture.new()
	tex.create_from_image(image)
	
	print(tex)
	
	# Assign to the child TextureRect node
	texture = tex
