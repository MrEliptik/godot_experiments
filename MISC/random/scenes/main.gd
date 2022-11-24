extends Control

onready var randf_btn: Button = $VBoxContainer/HBoxContainer/RandfContainer/RandfBtn
onready var randf_res: Label = $VBoxContainer/HBoxContainer/RandfContainer/Result
onready var randi_btn: Button = $VBoxContainer/HBoxContainer/RandiContainer/RandiBtn
onready var randi_res: Label = $VBoxContainer/HBoxContainer/RandiContainer/Result
onready var randfn_btn: Button = $VBoxContainer/HBoxContainer/RandfnContainer/RandfnBtn
onready var randfn_res: Label = $VBoxContainer/HBoxContainer/RandfnContainer/Result
onready var weighted_btn: Button = $VBoxContainer/HBoxContainer/WeightedContainer/WeightedBtn
onready var weighted_res: Label = $VBoxContainer/HBoxContainer/WeightedContainer/Result
onready var array_btn: Button = $VBoxContainer/HBoxContainer/ArrayContainer/ArrayBtn
onready var array_res: Label = $VBoxContainer/HBoxContainer/ArrayContainer/Result

var my_array = ["A", "B", "C", "D"]

var objects = ["First", "Second", "Third"]

var object_1 = {"name":"Object 1", "damage":55.0, "rarity":0.75}
var object_2 = {"name":"Object 2", "damage":23.0, "rarity":0.2}
var object_3 = {"name":"Object 3", "damage":150.0, "rarity":0.05}

var _objects = [object_1, object_2, object_3]

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	randomize()
	array_res.text = str(my_array)
	
	rng.randomize()
#	rng.seed = 564035 # Use custom seed to get reproducible outputs of random numbers

func _on_RandfBtn_pressed() -> void:
	var _min: float = 0.0
	var _max: float = 1.0
	if $VBoxContainer/HBoxContainer/RandfContainer/HBoxContainer/VBoxContainer/RandfMin.text != "":
		_min = float($VBoxContainer/HBoxContainer/RandfContainer/HBoxContainer/VBoxContainer/RandfMin.text)
	if $VBoxContainer/HBoxContainer/RandfContainer/HBoxContainer/VBoxContainer2/RandfMax.text != "":
		_max = float($VBoxContainer/HBoxContainer/RandfContainer/HBoxContainer/VBoxContainer2/RandfMax.text)
	randf_res.text = str(randf()*(_max-_min)+_min)
	
func _on_ResetRandfBtn_pressed() -> void:
	$VBoxContainer/HBoxContainer/RandfContainer/HBoxContainer/VBoxContainer/RandfMin.text = "0"
	$VBoxContainer/HBoxContainer/RandfContainer/HBoxContainer/VBoxContainer2/RandfMax.text = "1"

func _on_RandiBtn_pressed() -> void:
	var _min: int = 0
	var _max: int = 4294967295
	if $VBoxContainer/HBoxContainer/RandiContainer/HBoxContainer/VBoxContainer/RandiMin.text != "":
		_min = int($VBoxContainer/HBoxContainer/RandiContainer/HBoxContainer/VBoxContainer/RandiMin.text)
	if $VBoxContainer/HBoxContainer/RandiContainer/HBoxContainer/VBoxContainer2/RandiMax.text != "":
		_max = int($VBoxContainer/HBoxContainer/RandiContainer/HBoxContainer/VBoxContainer2/RandiMax.text)
	randi_res.text = str(randi()%(_max-(_min-1))+_min)
	
func _on_ResetRandiBtn_pressed() -> void:
	$VBoxContainer/HBoxContainer/RandiContainer/HBoxContainer/VBoxContainer/RandiMin.text = "0"
	$VBoxContainer/HBoxContainer/RandiContainer/HBoxContainer/VBoxContainer2/RandiMax.text = "4294967295"
	
func _on_RandfnBtn_pressed() -> void:
	randfn_res.text = str(rng.randfn())

func _on_WeightedBtn_pressed() -> void:
	var result = randf()
	if result < 0.1:
		weighted_res.text = objects[0]
	elif result < 0.7:
		weighted_res.text = objects[1]
	else:
		weighted_res.text = objects[2]

func _on_ArrayfBtn_pressed() -> void:
	var array_shuffled: Array = my_array.duplicate()
	array_shuffled.shuffle()
	array_res.text = str(array_shuffled)

func _on_NoiseBtn_pressed() -> void:
	$VBoxContainer/HBoxContainer/NoiseContainer/TextureResult.texture.noise.seed = randi()
