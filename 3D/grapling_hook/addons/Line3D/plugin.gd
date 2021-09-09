tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Line3D", "ImmediateGeometry", preload("res://addons/Line3D/Line3D.gd"), preload("res://addons/Line3D/line_3d.png"))

func _exit_tree():
	remove_custom_type("Line3D")
