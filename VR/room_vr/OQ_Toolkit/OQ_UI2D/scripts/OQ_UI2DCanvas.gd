tool
extends Spatial

var ui_control : Control = null;

onready var viewport = $Viewport;
onready var ui_area = $UIArea;
var ui_collisionshape = null;

export var editor_live_update := false;

export var transparent := false;

# set to true to prevent UIRayCast marker from colliding with canvas
export var disable_collision := false;

var mesh_material = null;
onready var mesh_instance : MeshInstance = $UIArea/UIMeshInstance


var ui_size = Vector2();

func _get_configuration_warning():
	if (ui_control == null): return "Need a Control node as child."
	return '';


func _input(event):
	if (event is InputEventKey):
		viewport.input(event);


func find_child_control():
	ui_control = null;
	for c in get_children():
		if c is Control:
			ui_control = c;
			break;

func update_size():
	ui_size = ui_control.get_size();
	if (ui_area != null):
		ui_area.scale.x = ui_size.x * vr.UI_PIXELS_TO_METER;
		ui_area.scale.y = ui_size.y * vr.UI_PIXELS_TO_METER;
	if (viewport != null):
		viewport.set_size(ui_size);


func _ready():
	
	mesh_material = mesh_instance.mesh.surface_get_material(0);
	# only enable transparency when necessary as it is significantly slower than non-transparent rendering
	mesh_material.flags_transparent = transparent;
	
	if Engine.editor_hint:
		return;

	find_child_control();

	if (!ui_control):
		vr.log_warning("No UI Control element found in OQ_UI2DCanvas: %s" % get_path());
		return;

	update_size();
	
	# reparent at runtime so we render to the viewport
	ui_control.get_parent().remove_child(ui_control);
	viewport.add_child(ui_control);
	ui_control.visible = true; # set visible here as it might was set invisible for editing multiple controls
	
	ui_collisionshape = $UIArea/UICollisionShape
	
	
func _editor_update_preview():
	var preview_node = ui_control.duplicate(DUPLICATE_USE_INSTANCING);
	preview_node.visible = true;
	
	for c in viewport.get_children():
		viewport.remove_child(c);
		c.queue_free();
	
	viewport.add_child(preview_node);


func _process(_dt):
	if !Engine.editor_hint: # not in edtior
		if disable_collision:
			ui_collisionshape.disabled = true;
		else:
			# if we are invisible we need to disable the collision shape to avoid interaction with the UIRayCast
			ui_collisionshape.disabled = not is_visible_in_tree()
		return;
		

	# Not sure if it is a good idea to do this in the _process but at the moment it seems to 
	# be the easiest to show the actual canvas size inside the editor
	var last = ui_control;
	find_child_control();
	if (ui_control != null):
		if (last != ui_control || ui_size != ui_control.get_size()):
			#print("Editor update size of ", name);
			update_size();
			_editor_update_preview();
		elif (editor_live_update):
			_editor_update_preview();



