shader_type canvas_item;

uniform sampler2D scratch_texture;

void fragment(){
	COLOR.rgb = texture(TEXTURE, UV).rgb;
	//COLOR.rgb =  vec3(UV.y);
	COLOR.a = texture(scratch_texture, SCREEN_UV).r;
	//COLOR.a = 1.;
}