extends RigidBody2D

var sprites = ["res://sprites/alienBeige_round.png", "res://sprites/alienBlue_round.png", 
	"res://sprites/alienGreen_round.png", "res://sprites/alienPink_round.png", "res://sprites/alienYellow_round.png"]

# Called when the node enters the scene tree for the first time.
func _ready():
	$ball.texture = load(sprites[int(rand_range(0, sprites.size()))])


