extends Camera

export(float) var speed = 8

func _process(_dt):
	var basis = self.global_transform.basis;
	var delta_move = Vector3(0, 0, 0);
	
	if (Input.is_key_pressed(KEY_W)): delta_move -= basis.z
	if (Input.is_key_pressed(KEY_A)): delta_move -= basis.x
	if (Input.is_key_pressed(KEY_S)): delta_move += basis.z
	if (Input.is_key_pressed(KEY_D)): delta_move += basis.x
	if (Input.is_key_pressed(KEY_Q)): delta_move -= basis.y
	if (Input.is_key_pressed(KEY_E)): delta_move += basis.y;
	
	if (delta_move.length_squared() > 0.001):
		self.global_transform.origin += delta_move.normalized() * speed * _dt;


func _input(event):
	# camera movement on mouse movement
	if (event is InputEventMouseMotion && Input.is_mouse_button_pressed(2)):
		var yaw = event.relative.x;
		var pitch = event.relative.y;
		self.rotate_y(deg2rad(-yaw));
		self.rotate_object_local(Vector3(1,0,0), deg2rad(-pitch));
