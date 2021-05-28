shader_type canvas_item;

uniform sampler2D mask_texture;

void fragment(){
	COLOR.rgb = texture(TEXTURE, UV).rgb;
	// We need to take 1 - texture because the texture will be black
	// by default
	COLOR.a = 1.0 - texture(mask_texture, UV).r;
}