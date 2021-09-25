shader_type spatial;

// Water
uniform float water_level: hint_range(0.0, 1.0) = 1.0;

void vertex() {
	VERTEX.y *= water_level;
	VERTEX.y += -0.5 + (water_level/2.0);
}


// Spatial material stuff
render_mode blend_mix,depth_draw_alpha_prepass,cull_disabled,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec4 transmission : hint_color;
uniform sampler2D texture_transmission : hint_black;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	ALPHA = albedo.a * albedo_tex.a;
	vec3 transmission_tex = texture(texture_transmission,base_uv).rgb;
	TRANSMISSION = (transmission.rgb+transmission_tex);
}
