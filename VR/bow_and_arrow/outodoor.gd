extends Spatial

var iTime=0.0
var iFrame=0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#iTime+=delta
	#iFrame+=1
	#$Sky.material_override.set("shader_param/iTime", iTime)
	#$Sky.material_override.set("shader_param/iFrame", iFrame)
