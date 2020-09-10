extends Spatial

const VU_COUNT = 13
const FREQ_MAX = 15000
const MIN_DB = 60
const HIDDEN_POS = -11.164
const MIN_ENERGY = 0.05

onready var _master = null
onready var _spectrum = null

var bars
var points

var previous_bars = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var previous_energy = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

var playing = true
var pitch_scale = 1.0
var play_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_spectrum = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index("Master"), 0)
	bars = $Bars.get_children()
	
	for i in range(0, VU_COUNT):
		bars[i].translation.y = randf()
		
	$AudioStreamPlayer.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _spectrum != null:
		#warning-ignore:integer_division
		var prev_hz = 0
		points = PoolVector2Array([])
		for i in range(1, VU_COUNT+1):	
			var hz = i * FREQ_MAX / VU_COUNT;
			var magnitude: float = _spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
			var energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
			var height = energy
			prev_hz = hz
			
			# Move the bar according to the energy
			#bars[i-1].translation.y = HIDDEN_POS + (abs(HIDDEN_POS) * energy)
			
			$Tween.interpolate_property(bars[i-1], "translation", 
				Vector3(bars[i-1].translation.x, previous_bars[i-1], bars[i-1].translation.z), 
				Vector3(bars[i-1].translation.x, HIDDEN_POS + (abs(HIDDEN_POS) * energy), bars[i-1].translation.z), 
				0.15, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
			$Tween.start()
			
			if energy >= MIN_ENERGY && !bars[i-1].get_node("AnimationPlayer").is_playing():
				bars[i-1].get_node("AnimationPlayer").play("Sing")
			elif energy < MIN_ENERGY:
				bars[i-1].get_node("AnimationPlayer").stop()
				
			if energy <= MIN_ENERGY && previous_energy[i-1] >= MIN_ENERGY:
				bars[i-1].get_node("AnimationPlayer2").play("Sleep")
			
			elif energy > MIN_ENERGY && previous_energy[i-1] <= MIN_ENERGY:
				bars[i-1].get_node("AnimationPlayer2").play("WakeUp")
			
			previous_bars[i-1] = HIDDEN_POS + (abs(HIDDEN_POS) * energy)
			previous_energy[i-1] = energy

func _on_GUI_play():
	if playing:
		play_pos = $AudioStreamPlayer.get_playback_position()
		$AudioStreamPlayer.stop()
	else:
		$AudioStreamPlayer.play(play_pos)
	playing = !playing
		#$myStreamPlayer2D.seek(temp)

func _on_GUI_slow_down():
	pitch_scale -= 0.25
	$AudioStreamPlayer.pitch_scale = pitch_scale


func _on_GUI_speed_up():
	pitch_scale += 0.25
	$AudioStreamPlayer.pitch_scale = pitch_scale
