extends Area2D

var speed = 100.0

var sprites = ["res://visuals/enemies/enemy_A.png", "res://visuals/enemies/enemy_B.png",
	"res://visuals/enemies/enemy_C.png", "res://visuals/enemies/enemy_D.png",
	"res://visuals/enemies/enemy_E.png"]

func _ready():
	$sprite.texture = load(sprites[int(rand_range(0, sprites.size()))])
	
func _process(delta):
	position.y += speed * delta

func die():
	call_deferred("queue_free")
