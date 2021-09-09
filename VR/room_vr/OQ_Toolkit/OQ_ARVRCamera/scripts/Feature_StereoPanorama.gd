tool
extends Spatial

export var far := 64.0 setget set_far;
export(Texture) var stereo_texture setget set_stereo_texture;

func set_stereo_texture(tex):
	stereo_texture = tex
	$ScreenQuad.get_surface_material(0).set_shader_param("stereo_image", tex);

func set_far(f):
	far = f;
	$ScreenQuad.translation.z = -far;
	$ScreenQuad.scale.x = far*far;
	$ScreenQuad.scale.y = far*far;

func _ready():
	if (not get_parent() is ARVRCamera):
		vr.log_error("Feature_StereoPanorama: parent is not ARVRCamera");

	set_far(far);
	set_stereo_texture(stereo_texture);
	
