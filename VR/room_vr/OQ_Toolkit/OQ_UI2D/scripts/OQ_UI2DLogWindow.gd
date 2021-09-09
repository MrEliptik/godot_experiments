extends Spatial

var last_log_pos = 0;
var log_label : Label = null;
var scroll : ScrollContainer = null;

func _ready():
	
	$OQ_UI2DCanvas.find_node("ReferenceRect", true, false).visible = true;

	# we need to use find_node here since the OQ_UI2DCanvas will reparent the UI to the
	# Viewport needed to render the UI to a texture;
	log_label = $OQ_UI2DCanvas.find_node("LogLabel", true, false);
	scroll = $OQ_UI2DCanvas.find_node("ScrollContainer", true, false);


func update_log():
	# this update the log by reinserting all mesages
	# !!TOOPT: can be optimized by just appending the not yet appended messages;
	#          but since the _log_buffer is a ring buffer we would need to take care of the wrap around
	log_label.text = "";
	for i in range(vr._log_buffer_count):
		var msg = vr._log_buffer[i % vr._log_buffer.size()];
		log_label.text += msg[1];
		if (msg[2] > 1): log_label.text += " [%d]" % msg[2];
		log_label.text += "\n";
		
	var sb = scroll.get_v_scrollbar();
	sb.value = sb.max_value; # autoscroll to the last line of the log buffer

func _process(_dt):
	if (vr._log_buffer_index != last_log_pos):
		update_log();
		last_log_pos = vr._log_buffer_index;
