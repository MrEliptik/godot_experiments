extends Spatial

export var MOVE_SPEED = 500

const MAX_FOV = 96
const MIN_FOV = 33

# Camera zoom & rotation
var mouse_sens = 0.15
var zoom_sens = 3
var middle_button_clicked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/GUI/HBoxContainer/Button.connect("pressed", self, "on_torque_btn_pressed")

func _unhandled_input(event):
	if event is InputEventMouseButton:

		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				$CameraRotationPoint/Camera.fov -= zoom_sens
				if $CameraRotationPoint/Camera.fov < MIN_FOV: $CameraRotationPoint/Camera.fov = MIN_FOV
			
			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				$CameraRotationPoint/Camera.fov += zoom_sens
				if $CameraRotationPoint/Camera.fov > MAX_FOV: $CameraRotationPoint/Camera.fov = MAX_FOV
			
		if event.button_index == 3:
			if event.is_pressed():
				middle_button_clicked = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				middle_button_clicked = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				
				
	if event is InputEventMouseMotion:
		if !middle_button_clicked: return
		$CameraRotationPoint.rotate_y(deg2rad(-event.relative.x*mouse_sens))
		var changev=-event.relative.y*mouse_sens

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_pressed("ui_left"):
		#$Cart.global_transform.origin.x -= MOVE_SPEED * delta
		$Cart.move_and_slide(-Vector3(MOVE_SPEED, 0.0, 0.0)*delta)
	elif Input.is_action_pressed("ui_right"):
		#$Cart.global_transform.origin.x += MOVE_SPEED * delta
		$Cart.move_and_slide(Vector3(MOVE_SPEED, 0.0, 0.0)*delta)

func _on_Cart_input_event(camera, event, click_position, click_normal, shape_idx):
	print(event)
	print(click_position)
	
func on_torque_btn_pressed():
	$Wheel.apply_torque_impulse(Vector3(0.0, 0.0, $CanvasLayer/GUI.get_torque()))
