extends Spatial

const roll_pack = preload("res://rollPack.tscn")

const PACK_THROW_FORCE = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	print('pressed')
	var roll_pack_clone
	roll_pack_clone = roll_pack.instance()
	roll_pack_clone.connect('explode', self, 'on_explode')

	
	get_tree().root.add_child(roll_pack_clone)
	roll_pack_clone.global_transform = $LaunchPoint.global_transform
	roll_pack_clone.apply_impulse(Vector3(0,0,0), roll_pack_clone.global_transform.basis.y * PACK_THROW_FORCE)
	$Thump.play()
