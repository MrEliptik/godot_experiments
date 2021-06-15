extends Node2D

signal new_accel_data(data)
signal connected(to_url)
signal disconnected()

# The port we will listen to
const PORT = 9080
# Our WebSocketServer instance
var server = WebSocketServer.new()

func _ready():
	# Connect base signals to get notified of new client connections,
	# disconnections, and disconnect requests.
	server.connect("client_connected", self, "_connected")
	server.connect("client_disconnected", self, "_disconnected")
	server.connect("client_close_request", self, "_close_request")
	# This signal is emitted when not using the Multiplayer API every time a
	# full packet is received.
	# Alternatively, you could check get_peer(PEER_ID).get_available_packets()
	# in a loop for each connected peer.
	server.connect("data_received", self, "_on_data")
	# Start listening on the given port.
	var err = server.listen(PORT)
	if err != OK:
		print("Unable to start server")
		set_process(false)
		
func _process(delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	server.poll()

func _connected(id, proto):
	# This is called when a new peer connects, "id" will be the assigned peer id,
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	print("Client %d connected with protocol: %s" % [id, proto])
	emit_signal("connected", server.get_peer_address(id))

func _close_request(id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _disconnected(id, was_clean = false):
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	emit_signal("disconnected")

func _on_data(id):
	# Print the received packet, you MUST always use get_peer(id).get_packet to receive data,
	# and not get_packet directly when not using the MultiplayerAPI.
	var pkt = server.get_peer(id).get_packet()
	#print("Got data from client %d: %s" % [id, pkt.get_string_from_utf8()])
#	server.get_peer(id).put_packet(pkt)
	emit_signal("new_accel_data",  pkt.get_string_from_utf8())
