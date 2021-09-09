extends Panel


onready var _refrence_button = $ReferenceButton;
onready var _container_letters = $Container_Letters
onready var _container_symbols = $Container_Symbols

export var allow_newline = false;

const B_SIZE = 48;

const NUMBER_LAYOUT = ["1","2","3","4","5","6","7","8","9","0"];

const BUTTON_LAYOUT_ENGLISH = [
["q","w","e","r","t","y","u","i","o","p"],
["a","s","d","f","g","h","j","k","l",":"],
["@","z","x","c","v","b","n","m","!","."],
["/"],
];

const BUTTON_LAYOUT_SYMBOLS = [
["!","@","#","$","%","^","&","*","(",")"],
[".",'"',"'",",","-","?",":",";","{","}"],
["+","_","=","|","/","\\","<",">","[","]"],
];


signal enter_pressed;
signal cancel_pressed;


var _all_letter_buttons = [];

func _toggle_case(upper):
	if (upper):
		for b in _all_letter_buttons:
			b.text = b.text.to_upper();
	else:
		for b in _all_letter_buttons:
			b.text = b.text.to_lower();
			
func _toggle_symbols(show_symbols):
	if (show_symbols):
		_container_letters.visible = false;
		_container_symbols.visible = true;
	else:
		_container_letters.visible = true;
		_container_symbols.visible = false;

func _create_input_event(b, pressed):
	var scancode = 0;
	var key = b.text;
	var unicode = 0;

	if (b == _toggle_symbols_button):
		_toggle_symbols(b.pressed);
		return;
	elif (b == _cancel_button):
		if (!pressed): emit_signal("cancel_pressed");
		return;
	elif (b == _shift_button):
		if (pressed): 
			_toggle_case(!b.pressed); # button event is created before it is actually toggled
		scancode = KEY_SHIFT;
	elif (b == _backspace_button):
		scancode = KEY_BACKSPACE;
	elif (b == _enter_button):
		scancode = KEY_ENTER;
		if (!pressed): emit_signal("enter_pressed");
		if (!allow_newline): return; # no key event for enter in this case
	elif (b == _space_button):
		scancode = KEY_SPACE;
		key = " ";
		unicode = " ".ord_at(0);
	else:
		scancode = OS.find_scancode_from_string(b.text);
		unicode = key.ord_at(0);
	

	#print("  Event for " + key + ": scancode = " + str(scancode));
	
	var ev = InputEventKey.new();
	ev.scancode = scancode;
	ev.unicode = unicode;
	ev.pressed = pressed;

	return ev;


# not sure what causes this yet but it happens that a button press
# triggers twice the down without up
var _last_button_down_hack = null;

func _on_button_down(b):
	if (b == _last_button_down_hack): return;
	_last_button_down_hack = b;
	
	var ev = _create_input_event(b, true);
	if (!ev): return;
	get_tree().input_event(ev);


func _on_button_up(b):
	_last_button_down_hack = null;
	
	var ev = _create_input_event(b, false);
	if (!ev): return;
	get_tree().input_event(ev);


func _create_button(_parent, text, x, y, w = 1, h = 1):
	var b = _refrence_button.duplicate();
	b.text = text;
	
	if (b.text.length() == 1):
		var c = b.text.ord_at(0);
		if (c >= 97 && c <= 122):
			_all_letter_buttons.append(b);
	
	b.rect_position = Vector2(x, y) * B_SIZE;
	b.rect_min_size = Vector2(w, h) * B_SIZE;
	
	b.name = "button_"+text;
	
	b.connect("button_down", self, "_on_button_down", [b]);
	b.connect("button_up", self, "_on_button_up", [b]);
	
	_parent.add_child(b);
	return b;

var _toggle_symbols_button : Button = null;
var _shift_button : Button = null;
var _backspace_button : Button = null;
var _enter_button : Button = null;
var _space_button : Button = null;
var _cancel_button : Button = null;

func _create_keyboard_buttons():
	_toggle_symbols_button = _create_button(self, "#$%", 0+1, 1, 2, 1);
	_toggle_symbols_button.set_rotation(deg2rad(90.0));
	_toggle_symbols_button.toggle_mode = true;
	
	_shift_button = _create_button(self, "Δ", 0, 3, 1, 2);
	_shift_button.toggle_mode = true;
	
	_backspace_button = _create_button(self, "BckSp.", 11+1, 1, 2, 1);
	_backspace_button.set_rotation(deg2rad(90.0));
	_enter_button = _create_button(self, "Enter", 11+1, 3, 2, 1);
	_enter_button.set_rotation(deg2rad(90.0));
	
	_space_button = _create_button(self, "Space", 2, 4, 9, 1);

	_cancel_button = _create_button(self, "X", 11, 0, 1, 1);
	
	var x = 1;
	var y = 0;
	
	for k in NUMBER_LAYOUT:
		_create_button(self, k, x, y);
		x += 1;
		
	

	x = 1;
	y = 1;
	# standard buttons
	for line in BUTTON_LAYOUT_ENGLISH:
		for k in line:
			_create_button(_container_letters, k, x, y);
			x += 1;
		y += 1;
		x = 1;
		
	x = 1;
	y = 1;
	# standard buttons
	for line in BUTTON_LAYOUT_SYMBOLS:
		for k in line:
			_create_button(_container_symbols, k, x, y);
			x += 1;
		y += 1;
		x = 1;

		
	_refrence_button.visible = false;
	_toggle_symbols(_toggle_symbols_button.pressed);



func _ready():
	_create_keyboard_buttons();
	pass # Replace with function body.
