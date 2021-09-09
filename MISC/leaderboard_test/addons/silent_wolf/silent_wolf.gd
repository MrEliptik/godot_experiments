tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("SilentWolf", "res://addons/silent_wolf/SilentWolf.gd")

func _exit_tree():
	remove_autoload_singleton("SilentWolf")
