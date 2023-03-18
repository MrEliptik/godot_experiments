extends Node2D

@export var spring: float = 150.0
@export var damp: float = 10.0
@export var scale_factor: float = 0.3

var displacement: float = 0.0 
var velocity: float = 0.0

@onready var rot_point = $RotPoint
@onready var character = $Character
@onready var punch_box = $PunchBox
@onready var bumper = $Bumper
@onready var tree = $Tree

func _ready():
	randomize()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		velocity = 30.0
	
	var force = -spring * displacement + damp * velocity
	velocity -= force * delta
	displacement -= velocity * delta
	
	rot_point.rotation = displacement
	bumper.scale = Vector2(0.438, 0.438) + Vector2(displacement, -displacement) * scale_factor
	tree.material.set_shader_parameter("rot", displacement*0.6)

func _on_spring_slider_value_changed(value):
	spring = value
	character.spring = value
	punch_box.spring = value
	$CanvasLayer/VBoxContainer/SpringContainer/Value.text = str(value)

func _on_damp_slider_value_changed(value):
	damp = value
	character.damp = value
	punch_box.damp = value
	$CanvasLayer/VBoxContainer/DampContainer/Value.text = str(value)
