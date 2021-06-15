extends Node

signal connected(to_url)
signal disconnected()

# The URL we will connect to
onready var websocket_url = ""

# Our WebSocketClient instance
var client = WebSocketClient.new()
var connected = false

func _ready():
	# Connect base signals to get notified of connection open, close, and errors.
	client.connect("connection_closed", self, "_closed")
	client.connect("connection_error", self, "_closed")
	client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	client.connect("data_received", self, "_on_data")
	
func _process(delta):	
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	client.poll()
	
func send_data(data):
	if !connected: return
	client.get_peer(1).put_packet(str(data).to_utf8())
	
func connect_ws(url):
	# Initiate connection to the given URL.
	print(client.get_connection_status())
	var err = client.connect_to_url(url)
	websocket_url = url
	if err != OK:
		print("Unable to connect")
	
func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	if !was_clean:
		client.disconnect_from_host()
	connected = false
	emit_signal("disconnected")

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	#client.get_peer(1).put_packet("Test packet".to_utf8())
	connected = true
	emit_signal("connected", client.get_connected_host())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	print("Got data from server: ", client.get_peer(1).get_packet().get_string_from_utf8())
