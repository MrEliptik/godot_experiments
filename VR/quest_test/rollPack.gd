extends RigidBody

signal explode(pack)

const texture = preload('res://model/rollPack/rollPack.material')

const EXPLOSION_FORCE = 10
const ROLL_NB = 8

const roll = preload('res://roll.tscn')
var glow = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_ExplosionTimer_timeout():
	var roll_clone
	
	$BlinkTimer.stop()
	$Explosion.play()
	
	sleeping = true
	visible = false
	
	for i in ROLL_NB:
		roll_clone = roll.instance()
		get_tree().root.add_child(roll_clone)
		var roll_body = roll_clone.get_node('Roll')
		roll_clone.global_transform = get_node('ExplosionPositions/Spatial'+str(i)).global_transform
		roll_body.apply_impulse(Vector3(0,0,0), get_node('ExplosionPositions/Spatial'+str(i)).global_transform.basis.y * EXPLOSION_FORCE)
	

func _on_BlinkTimer_timeout():
	if glow:
		$defaultMaterial.get_mesh().surface_get_material(0).emission_energy = 0
		glow = false
	else:
		$Beep.play()
		$defaultMaterial.get_mesh().surface_get_material(0).emission_energy = 1.19
		glow = true

func _on_BlinkDelayTimer_timeout():
	$BlinkTimer.start()

func _on_Explosion_finished():
	queue_free()
