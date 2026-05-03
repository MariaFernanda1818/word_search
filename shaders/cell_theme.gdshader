shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.18, 0.22, 0.30, 1.0);
uniform vec4 border_glow_color : source_color = vec4(0.43, 0.63, 1.0, 1.0);
uniform vec4 inner_glow_color : source_color = vec4(0.10, 0.20, 0.40, 1.0);

uniform float glow_strength = 0.35;
uniform float pulse_speed = 0.25;
uniform float scanline_strength = 0.08;

/*
	Qué tanto desaparece la letra.
	0.0 = casi no desaparece
	1.0 = desaparece bastante
*/
uniform float letter_fade_strength = 0.80;

/*
	Brillo mínimo de la letra cuando está en su punto más bajo.
	Sube este valor si se pierde demasiado.
*/
uniform float min_letter_visibility = 0.25;

void fragment() {
	vec4 original = texture(TEXTURE, UV) * COLOR;

	float border_x = min(UV.x, 1.0 - UV.x);
	float border_y = min(UV.y, 1.0 - UV.y);
	float border = min(border_x, border_y);

	float edge = smoothstep(0.18, 0.0, border);

	/*
		Pulso lento para que no parpadee rápido.
	*/
	float slow_time = TIME * pulse_speed;

	/*
		Onda de desvanecimiento.
		Va de 0 a 1 lentamente.
	*/
	float fade_wave = 0.5 + 0.5 * sin(slow_time);

	/*
		La letra baja y sube de intensidad.
		No desaparece al 100%, pero sí se nota el efecto.
	*/
	float letter_visibility = mix(
		1.0,
		min_letter_visibility + fade_wave * (1.0 - min_letter_visibility),
		letter_fade_strength
	);

	float pulse = 0.70 + 0.30 * sin(slow_time);

	float scanline = sin((UV.y * 30.0) + TIME * 0.45) * 0.5 + 0.5;

	vec3 shader_color = base_color.rgb;
	shader_color += inner_glow_color.rgb * 0.18;
	shader_color += border_glow_color.rgb * edge * glow_strength * pulse;
	shader_color += border_glow_color.rgb * scanline * scanline_strength;

	/*
		Detecta la letra blanca del Button.
	*/
	float original_brightness = max(max(original.r, original.g), original.b);
	float letter_mask = smoothstep(0.45, 0.95, original_brightness);

	/*
		Color de la letra más nítido.
	*/
	vec3 letter_color = mix(original.rgb, vec3(1.0), 0.45);

	/*
		Aplica la desaparición solo a la letra.
	*/
	letter_color *= letter_visibility;

	/*
		Mezcla celda + letra.
		Ahora la letra sí puede bajar bastante de intensidad.
	*/
	vec3 final_color = mix(shader_color, letter_color, letter_mask);

	COLOR = vec4(final_color, original.a);
}