shader_type canvas_item;

uniform vec4 text_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.3, 0.6, 1.0, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float glow_strength = 0.45;
uniform float pulse_speed = 1.2;
uniform float scanline_strength = 0.08;
uniform float distortion_strength = 0.001;

void fragment() {
	vec2 uv = UV;

	float wave = sin((uv.y + TIME * pulse_speed) * 35.0) * distortion_strength;
	vec2 distorted_uv = vec2(uv.x + wave, uv.y);

	vec4 tex = texture(TEXTURE, distorted_uv);

	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

	float scanline = sin((uv.y + TIME * 0.25) * 180.0);
	scanline = smoothstep(0.3, 1.0, scanline) * scanline_strength;

	vec3 final_color = text_color.rgb;
	final_color += glow_color.rgb * glow_strength * pulse * tex.a;
	final_color += glow_color.rgb * scanline * tex.a;

	COLOR = vec4(final_color, tex.a * text_color.a);
}