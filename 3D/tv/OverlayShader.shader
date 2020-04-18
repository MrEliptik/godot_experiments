shader_type canvas_item;
render_mode unshaded;

uniform sampler2D displace : hint_albedo;
uniform float dispAmt : hint_range(0, 0.1);
uniform float dispScale : hint_range(0.1, 2.0);
uniform float abberationAmt : hint_range(0, 0.1);
uniform float timeLine : hint_range(0.0, 10.0);

uniform float scanSpeed : hint_range(0.0, 100.0);
uniform float scanOffset : hint_range(0.0, 100.0);

uniform float screenCurvature : hint_range(0.0, 10.0);
uniform float curvatureDistance : 1.5;

vec2 distort(vec2 p) {

	float angle = p.y / p.x;
	float theta = atan(p.y, p.x);
	float radius = length(p);
	radius = pow(radius, screenCurvature);
	
	p.x = radius * cos(theta);
	p.y = radius * sin(theta);
	
	return 0.5 * (p + vec2(1.0,1.0));
}


void fragment() {
	
	// Remaping from 0:1 to -1:1
	vec2 p = (2.0 * SCREEN_UV) - 1.0;
	float d = length(p);
	if(d < curvatureDistance){
		p = distort(p);
	}else{
		p = SCREEN_UV;
	}
	
	// Displacement
	vec2 dispUv = p + vec2(0, TIME * 0.1);
	dispUv *= dispScale;
	vec2 disp = texture(displace, dispUv).xy;
	vec2 noiseUV = p + disp * dispAmt;
	
	// Noise Texture Sample
	float noise = texture(SCREEN_TEXTURE, noiseUV).r;
	
	// Horizontal Scan Lines
	float h = p.y * scanOffset - TIME * scanSpeed;
	h = clamp(1.0 - (abs(sin(h)) * 3.0), 0.0, 1.0);
	
	float clampedHLine = clamp(h * noise, 0.15, 1.0);
	
	float hLine = clampedHLine * noise;
	hLine *= 0.2;
	
	// Center "ball" thing
	vec2 cUv = p * 2.0 - 1.0;
	float tLine = pow(timeLine,2)*0.2;
	float modTLine = clamp(tLine / 4.0, 1.0, 8.0);
	modTLine = pow(modTLine, 2.5);
	cUv *= vec2(modTLine, tLine);
	
	float cBall =  2.0 * ((1.0 - length(cUv)) - 0.5);
	float cLine = pow(1.0 - length(vec2(cUv.g, 0.0)), 12.0);
	
	float center = 10.0 * ((cBall + cLine) - 0.1);
	
	float t = timeLine / 10.0;
	float final = (1.0-t)*hLine+t*center;
	
	// Abberation
	COLOR.r = texture(SCREEN_TEXTURE, noiseUV - abberationAmt * h).r;
	COLOR.g = texture(SCREEN_TEXTURE, noiseUV).g;
	COLOR.b = texture(SCREEN_TEXTURE, noiseUV + abberationAmt * h).b;
	COLOR.a = texture(SCREEN_TEXTURE, noiseUV).a;
	
	COLOR.rgb += vec3(final);
	
	//COLOR = texture(SCREEN_TEXTURE, p);
}