extends Control


onready var sfx_label: Label = $VBoxContainer/HBoxContainer/SFX
onready var music_label: Label = $VBoxContainer/HBoxContainer2/Music
onready var dialog_label: Label = $VBoxContainer/HBoxContainer3/Dialog

func _ready() -> void:
	pass

func _on_SFXSlider_value_changed(value: float) -> void:
	sfx_label.text = str(value)
	var value_in_db = linear2db(value/100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value_in_db)

func _on_MusicSlider_value_changed(value: float) -> void:
	music_label.text = str(value)
	var value_in_db = linear2db(value/100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value_in_db)

func _on_DialogSlider_value_changed(value: float) -> void:
	dialog_label.text = str(value)
	var value_in_db = linear2db(value/100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Dialog"), value_in_db)
