extends Control

func _ready():
	$Tween.interpolate_property($TextureRectTop.material, "shader_param/percentage",
		0.0, 1.0, 5.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
func set_loading_val(val):
	$TextureRect.material.set_shader_param("percentage", val/100.0)

func _on_HSlider_value_changed(value):
	set_loading_val(value)


func _on_Tween_tween_completed(object, key):
	$Tween.interpolate_property($TextureRectTop.material, "shader_param/percentage",
		0.0, 1.0, 5.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
