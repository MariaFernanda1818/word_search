shader_type canvas_item;

uniform vec4 background_color : source_color = vec4(0.07, 0.09, 0.12, 1.0);
uniform vec4 board_color : source_color = vec4(0.08, 0.22, 0.18, 1.0);
uniform vec4 paper_color : source_color = vec4(0.95, 0.88, 0.65, 1.0);
uniform vec4 chalk_color : source_color = vec4(0.90, 1.0, 0.88, 1.0);
uniform vec4 accent_color : source_color = vec4(1.0, 0.78, 0.25, 1.0);

uniform float line_density = 18.0;
uniform float symbol_density = 10.0;
uniform float animation_speed = 0.25;
uniform float glow_strength = 0.14;

float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float line_mask(float value, float width) {
	return 1.0 - smoothstep(width, width + 0.004, abs(value));
}

void fragment() {
	vec2 uv = UV;

	// Fondo tipo tablero de aula
	vec3 color = mix(background_color.rgb, board_color.rgb, uv.y);

	// Líneas horizontales suaves como cuaderno/tablero
	float notebook_lines = fract((uv.y + TIME * 0.006) * line_density);
	float horizontal_line = smoothstep(0.025, 0.0, notebook_lines);

	// Líneas verticales muy sutiles como margen de hoja
	float margin_line = line_mask(uv.x - 0.16, 0.002);

	color += chalk_color.rgb * horizontal_line * 0.10;
	color += accent_color.rgb * margin_line * 0.12;

	// Bloques suaves tipo hojas/cuadros de notas
	vec2 paper_uv_1 = uv - vec2(0.72, 0.25);
	vec2 paper_uv_2 = uv - vec2(0.24, 0.70);

	float paper_1 = step(abs(paper_uv_1.x), 0.10) * step(abs(paper_uv_1.y), 0.07);
	float paper_2 = step(abs(paper_uv_2.x), 0.12) * step(abs(paper_uv_2.y), 0.08);

	float paper_wave = 0.75 + 0.25 * sin(TIME * animation_speed);

	color = mix(color, paper_color.rgb, paper_1 * 0.08 * paper_wave);
	color = mix(color, paper_color.rgb, paper_2 * 0.07 * paper_wave);

	// Símbolos académicos abstractos: puntos y trazos suaves
	vec2 moving_uv = uv;
	moving_uv.y += TIME * animation_speed * 0.025;

	vec2 cell = floor(moving_uv * symbol_density);
	vec2 local = fract(moving_uv * symbol_density);

	float rnd = random(cell);

	// Punto tipo tiza
	float dot_shape = 1.0 - smoothstep(0.04, 0.09, distance(local, vec2(0.5)));
	float dot = dot_shape * step(0.86, rnd);

	// Trazo corto tipo signo o fórmula
	float stroke_horizontal = 1.0 - smoothstep(0.015, 0.025, abs(local.y - 0.5));
	stroke_horizontal *= step(0.25, local.x) * step(local.x, 0.75);

	float stroke_vertical = 1.0 - smoothstep(0.015, 0.025, abs(local.x - 0.5));
	stroke_vertical *= step(0.25, local.y) * step(local.y, 0.75);

	float symbol_type = step(0.93, rnd);
	float symbols = dot + ((stroke_horizontal + stroke_vertical) * symbol_type * 0.6);

	float symbol_pulse = 0.65 + 0.35 * sin(TIME * animation_speed + rnd * 6.2831);
	color += chalk_color.rgb * symbols * 0.13 * symbol_pulse;

	// Brillo central suave para que no se vea plano
	float glow_wave = sin((uv.x * 5.0) + (uv.y * 4.0) + TIME * 0.45) * 0.5 + 0.5;
	color += accent_color.rgb * glow_wave * glow_strength;

	// Viñeta
	float vignette = distance(uv, vec2(0.5));
	color *= smoothstep(0.95, 0.22, vignette);

	COLOR = vec4(color, 1.0);
}