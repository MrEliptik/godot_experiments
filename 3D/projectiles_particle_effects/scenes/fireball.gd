extends Spatial

var fire = false

func _ready():
	pass
	
func _physics_process(delta):
	if !fire: return
	
	transform.origin += -transform.basis.z*10*delta
	
func fire():
	fire = true
