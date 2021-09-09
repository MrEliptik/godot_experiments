extends Control

export var city_id: String = "3027422"
export var api_key: String = "c1e119496d44535f4cc34f1ffdfb11d9"

onready var url = "https://api.openweathermap.org/data/2.5/weather?id="+city_id+"&APPID="+api_key
onready var http_req = $HTTPRequest

func _ready():
	request_weather()

func request_weather():
	http_req.request(url)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code != 200: 
		print(response_code, body.get_string_from_utf8())
		return
		
	var json = JSON.parse(body.get_string_from_utf8())
	print(json)
