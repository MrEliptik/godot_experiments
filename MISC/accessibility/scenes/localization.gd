extends Control

onready var options: OptionButton = $VBoxContainer/OptionButton
onready var label: Label = $VBoxContainer/Label

var langs = ["en", "fr", "es"]

func _ready() -> void:
	fill_in_options()

func fill_in_options() -> void:
	for lang in langs:
		options.add_item(lang)

func _on_OptionButton_item_selected(index: int) -> void:
	# Here we set the locale of the translation server and
	# the UI elements using the keys will automatically be updated
	TranslationServer.set_locale(langs[index])
	# Example of using the translation function
	# tr() ir short for TranslationServer.translate()
	print(tr("HELLO"))
