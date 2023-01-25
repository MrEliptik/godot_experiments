extends Control

var remapping: bool = false

func _ready() -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if not remapping: return
	if event is InputEventKey:
		if not event.is_action("ui_cancel"):
			$Popup.visible = false
			# Remove all the old key bindings
			for old_event in InputMap.get_action_list("jump"):
				InputMap.action_erase_event("jump", old_event)
			var scancode = OS.get_scancode_string(event.scancode)
			$VBoxContainer/HboxContainer2/ActionKey.text = scancode
			# Add the new key binding
			InputMap.action_add_event("jump", event)
			remapping = false
			
func _process(delta: float) -> void:
	$VBoxContainer/HboxContainer3/ActionPressed.text = str(Input.is_action_pressed("jump"))    

func _on_RemapBtn_pressed() -> void:
	remapping = true
	$Popup.visible = true
