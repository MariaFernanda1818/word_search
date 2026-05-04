extends Control

##
# Referencia al GridContainer donde se dibuja
# dinámicamente la sopa de letras.
##
var grid_scroll: ScrollContainer
var grid: GridContainer

##
# Botón encargado de validar si la selección actual
# corresponde a una palabra correcta.
##
@onready var validate_button: Button = $Button

##
# Label principal utilizado para:
# - título del juego
# - mensajes de éxito
# - mensajes de error
##
@onready var result_label: Label = $Label

var validate_button_bg: Panel
var letter_tweens := {}

var title_theme_shader := preload("res://shaders/title_theme.gdshader")
var end_success_shader := preload("res://shaders/end_success.gdshader")
var end_fail_shader := preload("res://shaders/end_fail.gdshader")
var cell_theme_shader := preload("res://shaders/cell_theme.gdshader")
var cell_selected_shader := preload("res://shaders/cell_selected.gdshader")
var cell_correct_shader := preload("res://shaders/cell_correct.gdshader")
var cell_wrong_shader := preload("res://shaders/cell_wrong.gdshader")
var timer_theme_shader := preload("res://shaders/timer_theme.gdshader")
var button_theme_shader := preload("res://shaders/button_theme.gdshader")
var ui_panel_theme_shader := preload("res://shaders/ui_panel_theme.gdshader")
var ui_text_theme_shader := preload("res://shaders/ui_text_theme.gdshader")

var title_material: ShaderMaterial
var timer_material: ShaderMaterial
var validate_button_material: ShaderMaterial
var retry_button_material: ShaderMaterial
var normal_cell_material: ShaderMaterial
var hover_cell_material: ShaderMaterial
var selected_cell_material: ShaderMaterial
var correct_cell_material: ShaderMaterial
var wrong_cell_material: ShaderMaterial
var menu_panel_material: ShaderMaterial
var popup_panel_material: ShaderMaterial
var score_material: ShaderMaterial
var progress_material: ShaderMaterial
var feedback_panel_material: ShaderMaterial
var feedback_text_material: ShaderMaterial

##
# Shaders de fondo por nivel.
##
var technology_background_shader := preload("res://shaders/background_technology.gdshader")
var education_background_shader := preload("res://shaders/background_education.gdshader")
var nature_background_shader := preload("res://shaders/background_nature.gdshader")

##
# Fondo visual animado del nivel actual.
##
var background_rect: ColorRect

##
# Clase encargada de generar:
# - tamaño del tablero
# - ubicación de palabras
# - relleno aleatorio de letras
##
var generator := WordSearchGenerator.new()

##
# Clase encargada de construir el panel lateral
# donde se muestran las palabras pendientes
# y encontradas.
##
var word_panel := WordListPanel.new()

##
# Lista de palabras seleccionadas para la partida actual.
##
var words := []

##
# Matriz bidimensional con todas las letras
# de la sopa generada.
##
var letters := []

##
# Lista de botones actualmente seleccionados
# por el jugador.
##
var selected_cells: Array[Button] = []

##
# Lista de palabras ya encontradas correctamente.
##
var found_words := []

##
# Diccionario que guarda la definición educativa de cada palabra cargada.
##
var word_definitions := {}

##
# Sistema de puntaje y estadísticas.
##
var score := 0
var wrong_attempts := 0
var total_words_found := 0
var total_time_remaining := 0

##
# Labels adicionales del HUD.
##
var score_label: Label
var progress_label: Label
var feedback_label: Label
var feedback_panel: Panel

##
# Menú principal.
##
var menu_layer: CanvasLayer
var game_started := false

##
# Número total de filas del tablero.
##
var rows := 0

##
# Número total de columnas del tablero.
##
var cols := 0

##
# Tamaño visual de cada celda del tablero.
##
var cell_size := 0

##
# Estilos visuales reutilizados para las celdas:
# - normal
# - hover
# - seleccionada
# - correcta
# - incorrecta
##
var normal_style := StyleBoxFlat.new()
var hover_style := StyleBoxFlat.new()
var selected_style := StyleBoxFlat.new()
var correct_style := StyleBoxFlat.new()
var wrong_style := StyleBoxFlat.new()
var button_style := StyleBoxFlat.new()

##
# Label visual del temporizador.
##
var timer_label: Label

##
# Tiempo restante del nivel.
##
var time_left: float = 0

##
# Controla si el nivel ya terminó.
##
var level_finished := false

##
# Panel mostrado al terminar el nivel.
##
var end_panel: Panel

##
# Capa superior para mostrar el mensaje final encima de todo.
##
var end_layer: CanvasLayer

##
# Botón para reiniciar el nivel.
##
var retry_button: Button

##
# Nivel actual del juego.
##
var current_level := 0

##
# Sonidos del juego.
##
var select_sound := preload("res://sounds/click.mp3")
var correct_sound := preload("res://sounds/correct-word.mp3")
var wrong_sound := preload("res://sounds/fail-word.mp3")
var win_sound := preload("res://sounds/pass-level.mp3")
var lose_sound := preload("res://sounds/fail-level.mp3")
var final_win_sound := preload("res://sounds/win-game.mp3")
var background_music := preload("res://sounds/back-sound.mp3")

var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer


##
# Acción que ejecutará el botón del panel final.
# Puede ser:
# - "next"
# - "restart"
# - "retry_first"
##
var end_action := "restart"

##
# Inicializa toda la escena del juego.
#
# Flujo:
# 1. Inicializa aleatoriedad
# 2. Crea estilos visuales
# 3. Carga palabras desde archivo
# 4. Calcula tamaño del tablero
# 5. Calcula tamaño de celda
# 6. Genera la sopa de letras
# 7. Crea layout principal
# 8. Crea panel lateral de palabras
# 9. Crea la grilla interactiva
# 10. Conecta el botón de validación
##
func _ready() -> void:
	_configure_window()

	randomize()

	_create_audio_player()
	_play_background_music()
	_create_level_background()
	_ensure_grid_nodes()
	_create_styles()

	if not validate_button.pressed.is_connected(_on_validate_pressed):
		validate_button.pressed.connect(_on_validate_pressed)

	validate_button.visible = false
	result_label.visible = false

	_show_main_menu()

##
# Muestra el menú principal del juego.
##
func _show_main_menu() -> void:
	if menu_layer != null:
		menu_layer.queue_free()

	menu_layer = CanvasLayer.new()
	menu_layer.layer = 200
	add_child(menu_layer)

	var screen_size := get_viewport_rect().size

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.65)
	overlay.size = screen_size
	menu_layer.add_child(overlay)

	var panel := Panel.new()
	panel.size = Vector2(540, 450)
	panel.position = Vector2(
		(screen_size.x - panel.size.x) / 2.0,
		(screen_size.y - panel.size.y) / 2.0
	)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.14, 0.96)
	style.border_color = Color("#60a5fa")
	style.set_border_width_all(3)
	style.set_corner_radius_all(22)
	panel.add_theme_stylebox_override("panel", style)
	panel.material = _create_ui_panel_material_by_theme("technology", "menu")
	menu_layer.add_child(panel)
	var title := Label.new()
	title.text = "Sopa de Letras Educativa"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#dbeafe"))
	title.size = Vector2(540, 50)
	title.position = Vector2(0, 35)
	panel.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Aprende conceptos mientras encuentras palabras ocultas"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color("#cbd5e1"))
	subtitle.size = Vector2(540, 35)
	subtitle.position = Vector2(0, 90)
	panel.add_child(subtitle)

	var play_button := _create_menu_button("Jugar", Vector2(155, 155))
	var instructions_button := _create_menu_button("Instrucciones", Vector2(155, 220))
	var credits_button := _create_menu_button("Créditos", Vector2(155, 285))
	var exit_button := _create_menu_button("Salir", Vector2(155, 350))

	panel.add_child(play_button)
	panel.add_child(instructions_button)
	panel.add_child(credits_button)
	panel.add_child(exit_button)

	_apply_menu_button_shader(play_button, panel)
	_apply_menu_button_shader(instructions_button, panel)
	_apply_menu_button_shader(credits_button, panel)
	_apply_menu_button_shader(exit_button, panel)

	_connect_menu_button_sound(play_button)
	_connect_menu_button_sound(instructions_button)
	_connect_menu_button_sound(credits_button)
	_connect_menu_button_sound(exit_button)

	play_button.pressed.connect(_start_game_from_menu)
	instructions_button.pressed.connect(_show_instructions_panel)
	credits_button.pressed.connect(_show_credits_panel)
	exit_button.pressed.connect(func(): get_tree().quit())


func _apply_menu_button_shader(button: Button, parent: Control) -> void:
	if button.has_meta("shader_bg"):
		var old_bg = button.get_meta("shader_bg")
		if is_instance_valid(old_bg):
			old_bg.queue_free()
		button.remove_meta("shader_bg")

	var button_bg := Panel.new()
	button_bg.position = button.position
	button_bg.size = button.size
	button_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color.WHITE
	bg_style.border_color = Color.TRANSPARENT
	bg_style.set_border_width_all(0)
	bg_style.set_corner_radius_all(12)
	bg_style.set_content_margin_all(0)

	button_bg.add_theme_stylebox_override("panel", bg_style)
	button_bg.material = _create_menu_button_material()

	parent.add_child(button_bg)

	if button.get_parent() == parent:
		parent.move_child(button_bg, button.get_index())
		button.move_to_front()

	button.set_meta("shader_bg", button_bg)
	button.material = null

	var transparent_style := StyleBoxFlat.new()
	transparent_style.bg_color = Color(0, 0, 0, 0)
	transparent_style.border_color = Color(0, 0, 0, 0)
	transparent_style.set_border_width_all(0)
	transparent_style.set_corner_radius_all(12)
	transparent_style.set_content_margin_all(0)

	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("#cbd5e1"))
	button.add_theme_font_size_override("font_size", 19)

	button.add_theme_stylebox_override("normal", transparent_style)
	button.add_theme_stylebox_override("hover", transparent_style)
	button.add_theme_stylebox_override("pressed", transparent_style)
	button.add_theme_stylebox_override("focus", transparent_style)
	button.add_theme_stylebox_override("disabled", transparent_style)

	_connect_button_hover_animation(button)

func _create_menu_button_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = button_theme_shader

	material.set_shader_parameter("base_color", Color("#1d4ed8"))
	material.set_shader_parameter("border_color", Color("#60a5fa"))
	material.set_shader_parameter("glow_color", Color("#2563eb"))
	material.set_shader_parameter("shine_color", Color("#93c5fd"))
	material.set_shader_parameter("glow_strength", 0.34)
	material.set_shader_parameter("pulse_speed", 0.95)
	material.set_shader_parameter("shine_strength", 0.12)

	return material

func _create_menu_button(text: String, position: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.size = Vector2(230, 50)
	button.position = position
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 19)
	return button


func _start_game_from_menu() -> void:
	if menu_layer != null:
		menu_layer.queue_free()
		menu_layer = null

	game_started = true

	validate_button.visible = true
	result_label.visible = true

	score = 0
	wrong_attempts = 0
	total_words_found = 0
	total_time_remaining = 0

	_start_level(0)


func _show_instructions_panel() -> void:
	_show_info_popup(
		"Instrucciones",
		"Objetivo:\n" +
		"Encuentra todas las palabras ocultas antes de que termine el tiempo.\n\n" +

		"Cómo jugar:\n" +
		"Selecciona las letras que forman una palabra y presiona Validar.\n\n" +

		"Reglas:\n" +
		"Las palabras pueden estar en horizontal, vertical o diagonal.\n" +
		"También pueden aparecer hacia adelante o hacia atrás.\n\n" +

		"Puntaje:\n" +
		"+100 puntos por cada palabra correcta.\n" +
		"-20 puntos por cada error.\n" +
		"Al terminar un nivel, recibes bonus por el tiempo restante."
	)

func _show_credits_panel() -> void:
	_show_info_popup(
		"Créditos",
		"Proyecto Serious Game 2D\n\n" +

		"Desarrollado en Godot Engine.\n\n" +

		"Temáticas:\n" +
		"Tecnología, educación y naturaleza.\n\n" +

		"Recursos implementados:\n" +
		"Niveles, temporizador, sonidos, shaders, sistema de puntaje,\n" +
		"validación de palabras y retroalimentación educativa."
	)


func _show_info_popup(title_text: String, body_text: String) -> void:
	var popup_layer := CanvasLayer.new()
	popup_layer.layer = 250
	add_child(popup_layer)

	var screen_size: Vector2 = get_viewport_rect().size

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.60)
	overlay.size = screen_size
	popup_layer.add_child(overlay)

	var panel := Panel.new()
	panel.size = Vector2(760, 620)
	panel.position = Vector2(
		(screen_size.x - panel.size.x) / 2.0,
		(screen_size.y - panel.size.y) / 2.0
	)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.14, 0.98)
	style.border_color = Color("#60a5fa")
	style.set_border_width_all(3)
	style.set_corner_radius_all(20)
	panel.add_theme_stylebox_override("panel", style)
	panel.material = _create_ui_panel_material_by_theme(_get_active_theme(), "menu")
	popup_layer.add_child(panel)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#dbeafe"))
	title.material = _create_ui_text_material_by_theme(_get_active_theme(), "score")
	title.size = Vector2(760, 70)
	title.position = Vector2(0, 35)
	panel.add_child(title)

	var body := Label.new()
	body.text = body_text
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_color_override("font_color", Color("#e2e8f0"))
	body.add_theme_font_size_override("font_size", 18)
	body.size = Vector2(640, 380)
	body.position = Vector2(60, 120)
	panel.add_child(body)

	var close_button := Button.new()
	close_button.text = "Cerrar"
	close_button.size = Vector2(210, 52)
	close_button.position = Vector2(
		(panel.size.x - close_button.size.x) / 2.0,
		545
	)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_size_override("font_size", 19)
	panel.add_child(close_button)

	_apply_menu_button_shader(close_button, panel)
	_connect_menu_button_sound(close_button)

	close_button.pressed.connect(func():
		popup_layer.queue_free()
	)
##
# Crea el fondo animado donde se aplicará el shader de cada nivel.
##
func _create_level_background() -> void:
	var screen_size: Vector2 = get_viewport_rect().size

	background_rect = ColorRect.new()
	background_rect.size = screen_size
	background_rect.position = Vector2.ZERO
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(background_rect)
	move_child(background_rect, 0)

##
# Cambia el shader de fondo según el tema del nivel actual.
##
func _apply_level_background_shader() -> void:
	if background_rect == null:
		return

	var level_data: Dictionary = WordSearchConfig.LEVELS[current_level]
	var theme: String = String(level_data["theme"])

	var material := ShaderMaterial.new()

	match theme:
		"technology":
			material.shader = technology_background_shader

		"education":
			material.shader = education_background_shader

		"nature":
			material.shader = nature_background_shader

		_:
			material.shader = technology_background_shader

	background_rect.material = material
	background_rect.size = get_viewport_rect().size

##
# Inicia un nivel específico del juego.
##
func _start_level(level_index: int) -> void:
	_clear_current_level()

	current_level = level_index
	level_finished = false
	_play_background_music()

	_apply_level_background_shader()
	_apply_theme_cell_shaders()
	var level_data: Dictionary = WordSearchConfig.LEVELS[current_level]

	time_left = float(level_data["time"])

	cols = int(level_data["cols"])
	rows = int(level_data["rows"])

	var max_word_length: int = max(cols, rows)

	var theme: String = String(level_data["theme"])
	var words_file: String = _get_words_file_by_theme(theme)

	_load_random_words(
		int(level_data["words"]),
		max_word_length,
		words_file
	)

	print("Archivo usado: ", words_file)
	print("Palabras cargadas: ", words)
	print("Filas: ", rows, " Columnas: ", cols)

	generator.cols = cols
	generator.rows = rows
	
	_ensure_grid_nodes()
	
	if grid_scroll == null or grid == null:
		push_error("Faltan nodos en la escena. Debe existir GridScroll con un hijo llamado GridContainer.")
		return

	grid.columns = cols

	_calculate_cell_size()

	letters = generator.generate(words)

	_create_layout()
	_create_timer_label()
	_create_score_label()
	_create_progress_label()
	_create_feedback_label()
	_update_score_label()
	_update_progress_label()

	word_panel = WordListPanel.new()

	var level_theme: String = String(WordSearchConfig.LEVELS[current_level]["theme"])
	word_panel.create(self, words, get_viewport_rect().size, level_theme)

	_reposition_feedback_panel_under_word_panel()

	_create_grid()

	validate_button.disabled = false

	_show_message(
		_get_level_title(),
		Color("#ffffff")
	)

##
# Crea el label del puntaje.
##
func _create_score_label() -> void:
	var screen_size := get_viewport_rect().size
	var theme := _get_active_theme()

	score_label = Label.new()
	score_label.text = "Puntaje: 0"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.size = Vector2(240, 35)
	score_label.position = Vector2(screen_size.x - 440.0, 75.0)

	score_material = _create_ui_text_material_by_theme(theme, "score")
	score_label.material = score_material

	score_label.add_theme_font_size_override("font_size", 22)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_label.add_theme_constant_override("outline_size", 2)
	score_label.add_theme_color_override("font_outline_color", Color("#020617"))

	add_child(score_label)


##
# Crea el label de progreso.
##
func _create_progress_label() -> void:
	var screen_size := get_viewport_rect().size
	var theme := _get_active_theme()

	progress_label = Label.new()
	progress_label.text = "Progreso: 0 / 0"
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.size = Vector2(260, 35)
	progress_label.position = Vector2(screen_size.x - 450.0, 110.0)

	progress_material = _create_ui_text_material_by_theme(theme, "progress")
	progress_label.material = progress_material

	progress_label.add_theme_font_size_override("font_size", 21)
	progress_label.add_theme_color_override("font_color", Color.WHITE)
	progress_label.add_theme_constant_override("outline_size", 2)
	progress_label.add_theme_color_override("font_outline_color", Color("#020617"))

	add_child(progress_label)


##
# Crea el label de retroalimentación educativa.
##
func _create_feedback_label() -> void:
	if feedback_panel != null:
		feedback_panel.queue_free()
		feedback_panel = null

	var theme := _get_active_theme()

	feedback_panel = Panel.new()
	feedback_panel.size = Vector2(360, 210)
	feedback_panel.position = Vector2(35, 555)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(1, 1, 1, 0.08)
	panel_style.border_color = Color(1, 1, 1, 0.14)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(14)
	feedback_panel.add_theme_stylebox_override("panel", panel_style)

	feedback_panel_material = _create_ui_panel_material_by_theme(theme, "feedback")
	feedback_panel.material = feedback_panel_material

	add_child(feedback_panel)

	feedback_label = Label.new()
	feedback_label.text = "Encuentra una palabra para ver su significado."
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.size = Vector2(320, 170)
	feedback_label.position = Vector2(20, 20)

	feedback_text_material = _create_ui_text_material_by_theme(theme, "feedback")
	feedback_label.material = feedback_text_material

	feedback_label.add_theme_font_size_override("font_size", 17)
	feedback_label.add_theme_color_override("font_color", Color.WHITE)
	feedback_label.add_theme_constant_override("outline_size", 1)
	feedback_label.add_theme_color_override("font_outline_color", Color("#020617"))

	feedback_panel.add_child(feedback_label)

func _update_score_label() -> void:
	if score_label == null:
		return

	score_label.text = "Puntaje: " + str(score)


func _update_progress_label() -> void:
	if progress_label == null:
		return

	progress_label.text = "Progreso: " + str(found_words.size()) + " / " + str(words.size())


func _update_feedback_label(word: String) -> void:
	if feedback_label == null:
		return

	feedback_label.text = word + "\n" + _get_word_definition(word)


func _get_word_definition(word: String) -> String:
	var normalized_word := word.strip_edges().to_upper()

	if word_definitions.has(normalized_word):
		return word_definitions[normalized_word]

	return "Palabra relacionada con la temática del nivel."

##
# Crea y aplica shaders a las celdas según la temática del nivel.
##
func _apply_theme_cell_shaders() -> void:
	var level_data: Dictionary = WordSearchConfig.LEVELS[current_level]
	var theme: String = String(level_data["theme"])

	match theme:
		"technology":
			_create_cell_materials_by_theme(
				Color("#0b1220"),
				Color("#1e40af"),
				Color("#111827"),

				Color("#13203a"), 
				Color("#2563eb"),
				Color("#0f172a"), 

				Color("#1d4ed8"),
				Color("#60a5fa"),
				Color("#172554"), 

				Color("#0f766e"),
				Color("#5eead4"),
				Color("#134e4a"),

				Color("#7f1d1d"),
				Color("#f87171"),
				Color("#450a0a")
			)

		"education":
			_create_cell_materials_by_theme(
				Color("#3b2f1e"), 
				Color("#d6a84f"), 
				Color("#1f1608"),

				Color("#5a4527"),
				Color("#facc15"),
				Color("#3b2f1e"), 

				Color("#b7791f"), 
				Color("#fde68a"), 
				Color("#78350f"),

				Color("#15803d"),
				Color("#bbf7d0"), 
				Color("#14532d"), 

				Color("#b91c1c"), 
				Color("#fecaca"), 
				Color("#7f1d1d")  
			)

		"nature":
			_create_cell_materials_by_theme(
				Color("#123524"),
				Color("#4ade80"), 
				Color("#052e16"), 

				Color("#1f5f3b"), 
				Color("#86efac"),
				Color("#14532d"),

				Color("#65a30d"), 
				Color("#bef264"),
				Color("#365314"), 

				Color("#16a34a"), 
				Color("#bbf7d0"), 
				Color("#14532d"),

				Color("#991b1b"), 
				Color("#fecaca"),
				Color("#7f1d1d")  
			)

		_:
			_create_cell_materials_by_theme(
				Color("#2f3542"),
				Color("#70a1ff"),
				Color("#1e293b"),

				Color("#3d4658"),
				Color("#70a1ff"),
				Color("#1e293b"),

				Color("#ffa502"),
				Color("#ffdd59"),
				Color("#7c2d12"),

				Color("#2ed573"),
				Color("#7bed9f"),
				Color("#14532d"),

				Color("#ff4757"),
				Color("#ff6b81"),
				Color("#7f1d1d")
			)

##
# Construye los materiales shader para cada estado visual de las celdas.
##
func _create_cell_materials_by_theme(
	normal_base: Color,
	normal_glow: Color,
	normal_inner: Color,

	hover_base: Color,
	hover_glow: Color,
	hover_inner: Color,

	selected_base: Color,
	selected_glow: Color,
	selected_inner: Color,

	correct_base: Color,
	correct_glow: Color,
	correct_inner: Color,

	wrong_base: Color,
	wrong_glow: Color,
	wrong_inner: Color
) -> void:
	normal_cell_material = _create_cell_material(
		normal_base,
		normal_glow,
		normal_inner,
		0.12,
		0.18,
		0.025
	)

	hover_cell_material = _create_cell_material(
		hover_base,
		hover_glow,
		hover_inner,
		0.18,
		0.22,
		0.030
	)

	selected_cell_material = _create_state_material(
		cell_selected_shader,
		selected_base,
		selected_glow,
		0.32,
		1.15
	)

	correct_cell_material = _create_state_material(
		cell_correct_shader,
		correct_base,
		correct_glow,
		0.35,
		0.85
	)

	wrong_cell_material = _create_state_material(
		cell_wrong_shader,
		wrong_base,
		wrong_glow,
		0.42,
		1.70
	)

	_apply_cell_stylebox_palette(
		normal_base,
		normal_glow,
		hover_base,
		hover_glow,
		selected_base,
		selected_glow,
		correct_base,
		correct_glow,
		wrong_base,
		wrong_glow
	)

func _apply_cell_stylebox_palette(
	normal_base: Color,
	normal_border: Color,
	hover_base: Color,
	hover_border: Color,
	selected_base: Color,
	selected_border: Color,
	correct_base: Color,
	correct_border: Color,
	wrong_base: Color,
	wrong_border: Color
) -> void:
	normal_style.bg_color = normal_base
	normal_style.border_color = normal_border
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(5)
	normal_style.set_content_margin_all(0)

	hover_style = normal_style.duplicate()
	hover_style.bg_color = hover_base
	hover_style.border_color = hover_border

	selected_style = normal_style.duplicate()
	selected_style.bg_color = selected_base
	selected_style.border_color = selected_border

	correct_style = normal_style.duplicate()
	correct_style.bg_color = correct_base
	correct_style.border_color = correct_border

	wrong_style = normal_style.duplicate()
	wrong_style.bg_color = wrong_base
	wrong_style.border_color = wrong_border

##
# Crea un ShaderMaterial individual para una celda.
##
func _create_cell_material(
	base_color: Color,
	border_glow_color: Color,
	inner_glow_color: Color,
	glow_strength: float,
	pulse_speed: float,
	scanline_strength: float
) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = cell_theme_shader
	material.set_shader_parameter("base_color", base_color)
	material.set_shader_parameter("border_glow_color", border_glow_color)
	material.set_shader_parameter("inner_glow_color", inner_glow_color)
	material.set_shader_parameter("glow_strength", glow_strength)
	material.set_shader_parameter("pulse_speed", pulse_speed)
	material.set_shader_parameter("scanline_strength", scanline_strength)

	material.set_shader_parameter("letter_fade_strength", 0.80)

	material.set_shader_parameter("min_letter_visibility", 0.25)

	return material

func _create_state_material(
	shader: Shader,
	base_color: Color,
	glow_color: Color,
	glow_strength: float,
	pulse_speed: float
) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", base_color)
	material.set_shader_parameter("glow_color", glow_color)
	material.set_shader_parameter("glow_strength", glow_strength)
	material.set_shader_parameter("pulse_speed", pulse_speed)
	return material
	
##
# Limpia la información visual y lógica del nivel actual.
##
func _clear_current_level() -> void:
	if validate_button != null and validate_button.has_meta("shader_bg"):
		var bg = validate_button.get_meta("shader_bg")
		if is_instance_valid(bg):
			bg.queue_free()
		validate_button.remove_meta("shader_bg")

	validate_button_bg = null

	for button in letter_tweens.keys():
		if letter_tweens[button] != null:
			letter_tweens[button].kill()

	letter_tweens.clear()

	selected_cells.clear()
	found_words.clear()
	words.clear()
	letters.clear()
	word_definitions.clear()

	if grid != null:
		for child in grid.get_children():
			child.queue_free()
	else:
		push_error("GridContainer no encontrado. Revisa que exista: GridScroll/GridContainer")

	if word_panel != null and word_panel.panel != null:
		word_panel.panel.queue_free()

	if timer_label != null:
		timer_label.queue_free()
		timer_label = null

	if score_label != null:
		score_label.queue_free()
		score_label = null

	if progress_label != null:
		progress_label.queue_free()
		progress_label = null

	if feedback_panel != null:
		feedback_panel.queue_free()
		feedback_panel = null

	feedback_label = null
	score_material = null
	progress_material = null
	feedback_panel_material = null
	feedback_text_material = null

	if end_layer != null:
		end_layer.queue_free()
		end_layer = null

	if validate_button != null:
		validate_button.disabled = false

##
# Carga palabras aleatorias desde un archivo JSON.
#
# El JSON debe tener esta estructura:
# [
#   {
#     "name": "GODOT",
#     "definition": "Motor de videojuegos usado para crear juegos 2D y 3D."
#   }
# ]
##
func _load_random_words(amount: int, max_length: int, words_file: String) -> void:
	var file := FileAccess.open(words_file, FileAccess.READ)

	if file == null:
		push_error("No se pudo abrir el archivo de palabras: " + words_file)
		words.clear()
		word_definitions.clear()
		return

	var json_text := file.get_as_text()
	file.close()

	var parsed_data = JSON.parse_string(json_text)

	if parsed_data == null:
		push_error("El archivo JSON no tiene un formato válido: " + words_file)
		words.clear()
		word_definitions.clear()
		return

	if typeof(parsed_data) != TYPE_ARRAY:
		push_error("El JSON debe ser un arreglo de objetos: " + words_file)
		words.clear()
		word_definitions.clear()
		return

	var all_words := []
	word_definitions.clear()

	for item in parsed_data:
		if typeof(item) != TYPE_DICTIONARY:
			continue

		if not item.has("name"):
			continue

		var word := String(item["name"]).strip_edges().to_upper()

		if word == "":
			continue

		if word.length() > max_length:
			continue

		if all_words.has(word):
			continue

		var definition := "Palabra relacionada con la temática del nivel."

		if item.has("definition"):
			definition = String(item["definition"]).strip_edges()

		all_words.append(word)
		word_definitions[word] = definition

	all_words.shuffle()
	words.clear()

	for i in range(min(amount, all_words.size())):
		words.append(all_words[i])

	if words.size() < amount:
		push_warning(
			"El archivo " + words_file +
			" solo tiene " + str(words.size()) +
			" palabras válidas para este nivel."
		)

##
# Crea y posiciona los elementos principales de la interfaz:
# - título/mensaje
# - grilla
# - botón validar
##
func _create_layout() -> void:
	var screen_size: Vector2 = get_viewport_rect().size

	result_label.text = _get_level_title()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.size = Vector2(900, 55)
	result_label.position = Vector2((screen_size.x - result_label.size.x) / 2.0, 25.0)

	_apply_title_theme()

	var separation: int = 6
	var grid_width: float = float(cols * cell_size + ((cols - 1) * separation))
	var grid_height: float = float(rows * cell_size + ((rows - 1) * separation))

	var left_panel_width: float = 360.0
	var right_padding: float = 80.0

	var playable_area_x: float = left_panel_width
	var playable_area_width: float = screen_size.x - left_panel_width - right_padding
	var playable_center_x: float = playable_area_x + (playable_area_width / 2.0)

	var grid_container_width: float = grid_width + 20.0
	var grid_container_height: float = grid_height + 20.0

	validate_button.text = "Validar"
	validate_button.size = Vector2(190, 50)

	var button_y: float = screen_size.y - 95.0
	var button_gap: float = 45.0

	validate_button.position = Vector2(
		playable_center_x - (validate_button.size.x / 2.0),
		button_y
	)

	var grid_global_x: float = playable_center_x - (grid_container_width / 2.0)
	var grid_global_y: float = button_y - button_gap - grid_container_height

	grid_global_y = maxf(grid_global_y, 105.0)

	grid_scroll.position = Vector2(grid_global_x, grid_global_y)
	grid_scroll.size = Vector2(grid_container_width, grid_container_height)

	grid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	grid_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	grid.position = Vector2(10, 10)

	grid.add_theme_constant_override("h_separation", separation)
	grid.add_theme_constant_override("v_separation", separation)

	_apply_button_shader(validate_button, self, false)
##
# Construye la grilla de botones de la sopa.
##
func _create_grid() -> void:
	for row in range(rows):
		for col in range(cols):
			var button := Button.new()
			button.text = letters[row][col]

			button.custom_minimum_size = Vector2(cell_size, cell_size)
			button.size = Vector2(cell_size, cell_size)
			button.focus_mode = Control.FOCUS_NONE
			button.clip_text = true

			button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			button.size_flags_vertical = Control.SIZE_SHRINK_CENTER

			button.add_theme_constant_override("h_separation", 0)
			button.add_theme_constant_override("icon_max_width", 0)

			button.set_meta("row", row)
			button.set_meta("col", col)

			_apply_normal_style(button)
			_start_letter_fade(button)

			button.mouse_entered.connect(func():
				if not selected_cells.has(button) and not _is_cell_found(button):
					button.material = hover_cell_material
			)

			button.mouse_exited.connect(func():
				if not selected_cells.has(button) and not _is_cell_found(button):
					button.material = normal_cell_material
			)
			button.pressed.connect(func(): _on_cell_pressed(button))
			grid.add_child(button)

##
# Maneja la selección y deselección de celdas.
#
# @param button Celda seleccionada
##
func _on_cell_pressed(button: Button) -> void:
	if level_finished:
		return
	if selected_cells.has(button):
		selected_cells.erase(button)

		if _is_cell_found(button):
			_apply_correct_style(button)
		else:
			_apply_normal_style(button)

		_animate_cell(button, 1.0)
		_play_sfx(select_sound, -14.0, 1.15)
		return

	selected_cells.append(button)
	_apply_selected_style(button)
	_animate_cell(button, 1.15)
	_play_sfx(select_sound, -16.0, 0.85)

##
# Valida si la selección actual corresponde a una palabra.
##
func _on_validate_pressed() -> void:
	if level_finished:
		return

	if selected_cells.is_empty():
		_show_message("Selecciona una palabra", Color("#ffa502"))
		return

	var matched_word := _get_matched_word_from_selection()

	if matched_word != "":
		_register_correct_word(matched_word)
	else:
		await _register_wrong_selection()

##
# Busca si las posiciones seleccionadas coinciden con una palabra.
#
# @return palabra encontrada o vacío
##
func _get_matched_word_from_selection() -> String:
	var selected_positions := _get_selected_positions()

	for word in words:
		if found_words.has(word):
			continue

		if not generator.word_positions.has(word):
			continue

		var word_positions: Array = generator.word_positions[word]

		if _same_positions(selected_positions, word_positions):
			return word

	return ""

##
# Obtiene las posiciones de las celdas seleccionadas.
#
# @return lista de posiciones
##
func _get_selected_positions() -> Array:
	var positions := []

	for cell in selected_cells:
		var col: int = cell.get_meta("col")
		var row: int = cell.get_meta("row")
		positions.append(Vector2i(col, row))

	return positions

##
# Compara si la selección coincide con las posiciones reales de una palabra.
#
# Valida en orden normal o inverso.
# Esto evita aceptar letras dispersas o seleccionadas sin secuencia.
##
func _same_positions(selected_positions: Array, word_positions: Array) -> bool:
	if selected_positions.size() != word_positions.size():
		return false

	for position in selected_positions:
		if not word_positions.has(position):
			return false

	return true

##
# Marca una palabra como correcta.
#
# Suma puntaje, actualiza progreso y muestra retroalimentación educativa.
##
func _register_correct_word(word: String) -> void:
	_play_sfx(correct_sound, -10.0, 1.0)

	score += 100
	total_words_found += 1

	found_words.append(word)

	_show_message("Correcto: " + word, Color("#2ed573"))
	_update_feedback_label(word)
	_update_score_label()
	_update_progress_label()

	word_panel.mark_found(word)

	for cell in selected_cells:
		cell.set_meta("found", true)
		_apply_correct_style(cell)
		_animate_cell(cell, 1.15)

	selected_cells.clear()

	if found_words.size() == words.size():
		_win_level()
##
# Finaliza el nivel como exitoso cuando se encuentran todas las palabras.
##
func _win_level() -> void:
	level_finished = true
	var time_bonus := int(ceil(time_left))
	score += time_bonus
	total_time_remaining += time_bonus
	_update_score_label()
	if current_level == WordSearchConfig.LEVELS.size() - 1:
		_play_sfx(final_win_sound, -8.0, 1.0)
	else:
		_play_sfx(win_sound, -9.0, 1.0)

	validate_button.disabled = true

	for child in grid.get_children():
		if child is Button:
			child.disabled = true

	if current_level < WordSearchConfig.LEVELS.size() - 1:
		end_action = "next"

		_show_message("Nivel completado exitosamente", Color("#2ed573"))

		_show_end_message(
			"Nivel exitoso",
			"Pasas al " + String(WordSearchConfig.LEVELS[current_level + 1]["name"]),
			Color("#2ed573"),
			"Siguiente nivel"
		)
	else:
		end_action = "restart"

		_show_message("Juego completado exitosamente", Color("#2ed573"))

		_show_end_message(
			"Juego completado",
			_get_final_summary_text(),
			Color("#2ed573"),
			"Jugar de nuevo"
		)

##
# Construye el resumen final del juego.
##
func _get_final_summary_text() -> String:
	return "Puntaje final: " + str(score) + "\n" + \
		"Palabras encontradas: " + str(total_words_found) + "\n" + \
		"Errores cometidos: " + str(wrong_attempts) + "\n" + \
		"Tiempo restante total: " + _format_seconds(total_time_remaining)


func _format_seconds(total_seconds: int) -> String:
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60

	return "%02d:%02d" % [minutes, seconds]

##
# Marca una selección incorrecta.
#
# Resta puntaje y registra el error.
##
func _register_wrong_selection() -> void:
	_play_sfx(wrong_sound, -11.0, 0.95)

	wrong_attempts += 1
	score = max(0, score - 20)

	_show_message("No es una palabra válida", Color("#ff4757"))
	_update_score_label()

	if feedback_label != null:
		feedback_label.text = "La selección debe corresponder a una palabra oculta completa."
	for cell in selected_cells:
		_apply_wrong_style(cell)
		await get_tree().create_timer(0.8).timeout

		if _is_cell_found(cell):
			_apply_correct_style(cell)
		else:
			_apply_normal_style(cell)

	selected_cells.clear()

##
# Construye la palabra a partir de las letras seleccionadas.
#
# @return palabra formada
##
func _get_selected_word() -> String:
	var word := ""

	for cell in selected_cells:
		word += cell.text

	return word


##
# Muestra un mensaje en pantalla.
#
# @param text mensaje
# @param color color del texto
##
func _show_message(text: String, color: Color) -> void:
	result_label.text = text
	result_label.add_theme_color_override("font_color", Color.WHITE)

	if title_material == null:
		return

	if text.contains("Sopa de letras"):
		title_material = _create_title_material_by_theme()
		result_label.material = title_material
		return

	if text.to_lower().contains("correcto") or text.to_lower().contains("exitosamente"):
		title_material.set_shader_parameter("text_color", Color("#bbf7d0"))
		title_material.set_shader_parameter("glow_color", Color("#22c55e"))
	elif text.to_lower().contains("fallido") or text.to_lower().contains("válida") or text.to_lower().contains("selecciona"):
		title_material.set_shader_parameter("text_color", Color("#fecaca"))
		title_material.set_shader_parameter("glow_color", Color("#ef4444"))
	else:
		title_material = _create_title_material_by_theme()
		result_label.material = title_material

##
# Valida si una celda ya fue encontrada.
#
# @return true si ya fue encontrada
##
func _is_cell_found(button: Button) -> bool:
	return button.get_meta("found", false)


##
# Calcula el tamaño de cada celda según pantalla.
##
func _calculate_cell_size() -> void:
	match current_level:
		0:
			cell_size = 42
		1:
			cell_size = 39
		2:
			cell_size = 36
		_:
			cell_size = 38
	
##
# Ejecuta animación visual de una celda.
#
# @param button botón a animar
# @param scale_value escala temporal
##
func _animate_cell(button: Button, scale_value: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	button.pivot_offset = button.size / 2
	tween.tween_property(button, "scale", Vector2(scale_value, scale_value), 0.12)
	tween.tween_property(button, "scale", Vector2.ONE, 0.12)

##
# Crea todos los estilos visuales.
##
func _create_styles() -> void:
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(5)
	normal_style.set_content_margin_all(0)

	button_style.bg_color = Color("#3742fa")
	button_style.set_corner_radius_all(12)

##
# Aplica estilo normal a una celda.
##
func _apply_normal_style(button: Button) -> void:
	var font_size: int = 16

	if cell_size >= 42:
		font_size = 22
	elif cell_size >= 39:
		font_size = 20
	elif cell_size >= 36:
		font_size = 18
	else:
		font_size = 16

	button.material = normal_cell_material

	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color.WHITE)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", selected_style)
	button.add_theme_stylebox_override("focus", normal_style)

func _apply_selected_style(button: Button) -> void:
	button.material = selected_cell_material
	button.add_theme_stylebox_override("normal", selected_style)
	button.add_theme_stylebox_override("hover", selected_style)
	button.add_theme_stylebox_override("pressed", selected_style)


func _apply_correct_style(button: Button) -> void:
	button.material = correct_cell_material
	button.add_theme_stylebox_override("normal", correct_style)
	button.add_theme_stylebox_override("hover", correct_style)
	button.add_theme_stylebox_override("pressed", correct_style)


func _apply_wrong_style(button: Button) -> void:
	button.material = wrong_cell_material
	button.add_theme_stylebox_override("normal", wrong_style)
	button.add_theme_stylebox_override("hover", wrong_style)
	button.add_theme_stylebox_override("pressed", wrong_style)




##
# Actualiza el temporizador del nivel.
##
func _process(delta: float) -> void:
	if not game_started:
		return

	if level_finished:
		return

	time_left -= delta

	if time_left <= 0:
		time_left = 0
		_update_timer_label()
		_fail_level()
		return

	_update_timer_label()

##
# Crea el label del temporizador en pantalla.
##
func _create_timer_label() -> void:
	var screen_size: Vector2 = get_viewport_rect().size

	timer_label = Label.new()
	timer_label.text = "Tiempo: 00:00"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.size = Vector2(280, 45)
	timer_label.position = Vector2(screen_size.x - 440.0, 30.0)

	timer_material = _create_timer_material_by_theme()
	timer_label.material = timer_material

	_apply_timer_theme_font()

	add_child(timer_label)

	_update_timer_label()


##
# Cambia tamaño, sombra y estilo visual del temporizador según la temática.
##
func _apply_timer_theme_font() -> void:
	if timer_label == null:
		return

	var level_data: Dictionary = WordSearchConfig.LEVELS[current_level]
	var theme: String = String(level_data["theme"])

	match theme:
		"technology":
			timer_label.add_theme_font_size_override("font_size", 24)
			timer_label.add_theme_constant_override("outline_size", 2)
			timer_label.add_theme_color_override("font_outline_color", Color("#0f172a"))

		"education":
			timer_label.add_theme_font_size_override("font_size", 23)
			timer_label.add_theme_constant_override("outline_size", 1)
			timer_label.add_theme_color_override("font_outline_color", Color("#3b2f1e"))

		"nature":
			timer_label.add_theme_font_size_override("font_size", 23)
			timer_label.add_theme_constant_override("outline_size", 2)
			timer_label.add_theme_color_override("font_outline_color", Color("#052e16"))

		_:
			timer_label.add_theme_font_size_override("font_size", 22)
			timer_label.add_theme_constant_override("outline_size", 1)
			timer_label.add_theme_color_override("font_outline_color", Color("#000000"))

	timer_label.add_theme_color_override("font_color", Color.WHITE)

##
# Actualiza el texto del temporizador.
##
func _update_timer_label() -> void:
	if timer_label == null:
		return

	var total_seconds := int(ceil(time_left))
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60

	timer_label.text = "Tiempo: %02d:%02d" % [minutes, seconds]

	if timer_material == null:
		return

	if total_seconds <= 10:
		timer_material.set_shader_parameter("text_color", Color("#ff4757"))
		timer_material.set_shader_parameter("glow_color", Color("#ff6b81"))
		timer_material.set_shader_parameter("glow_strength", 0.75)
		timer_material.set_shader_parameter("pulse_speed", 3.2)
		timer_material.set_shader_parameter("distortion_strength", 0.004)

	elif total_seconds <= 30:
		timer_material.set_shader_parameter("text_color", Color("#f97316"))
		timer_material.set_shader_parameter("glow_color", Color("#fdba74"))
		timer_material.set_shader_parameter("glow_strength", 0.55)
		timer_material.set_shader_parameter("pulse_speed", 2.0)
		timer_material.set_shader_parameter("distortion_strength", 0.002)

	else:
		var theme: String = String(WordSearchConfig.LEVELS[current_level]["theme"])

		match theme:
			"technology":
				timer_material.set_shader_parameter("text_color", Color("#60a5fa"))
				timer_material.set_shader_parameter("glow_color", Color("#1d4ed8"))
				timer_material.set_shader_parameter("glow_strength", 0.45)
				timer_material.set_shader_parameter("pulse_speed", 1.8)
				timer_material.set_shader_parameter("distortion_strength", 0.003)

			"education":
				timer_material.set_shader_parameter("text_color", Color("#facc15"))
				timer_material.set_shader_parameter("glow_color", Color("#b7791f"))
				timer_material.set_shader_parameter("glow_strength", 0.35)
				timer_material.set_shader_parameter("pulse_speed", 1.1)
				timer_material.set_shader_parameter("distortion_strength", 0.001)

			"nature":
				timer_material.set_shader_parameter("text_color", Color("#86efac"))
				timer_material.set_shader_parameter("glow_color", Color("#16a34a"))
				timer_material.set_shader_parameter("glow_strength", 0.38)
				timer_material.set_shader_parameter("pulse_speed", 0.9)
				timer_material.set_shader_parameter("distortion_strength", 0.0015)


##
# Finaliza el nivel como fallido cuando se acaba el tiempo.
##
func _fail_level() -> void:
	level_finished = true
	_play_sfx(lose_sound, -10.0, 1.0)

	_show_message("Tiempo terminado. Nivel fallido", Color("#ff4757"))

	validate_button.disabled = true

	for child in grid.get_children():
		if child is Button:
			child.disabled = true

	end_action = "retry_first"

	_show_end_message(
		"Nivel fallido",
		"Debes volver al Nivel 1",
		Color("#ff4757"),
		"Reintentar desde Nivel 1"
	)

##
# Muestra un mensaje visual grande cuando el jugador gana o pierde.
##
func _show_end_message(
	title_text: String,
	description_text: String,
	border_color: Color,
	button_text: String
) -> void:
	if end_layer != null:
		end_layer.queue_free()

	var screen_size := get_viewport_rect().size

	end_layer = CanvasLayer.new()
	end_layer.layer = 100
	add_child(end_layer)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.45)
	overlay.size = screen_size
	overlay.position = Vector2.ZERO
	end_layer.add_child(overlay)

	end_panel = Panel.new()
	end_panel.size = Vector2(500, 270)
	end_panel.position = Vector2(
		(screen_size.x - end_panel.size.x) / 2,
		(screen_size.y - end_panel.size.y) / 2
	)

	var end_style := StyleBoxFlat.new()
	end_style.bg_color = Color(1, 1, 1, 0.08)
	end_style.border_color = Color(1, 1, 1, 0.10)
	end_style.set_border_width_all(3)
	end_style.set_corner_radius_all(18)
	end_panel.add_theme_stylebox_override("panel", end_style)

	var is_success := title_text.to_lower().contains("exitoso") or title_text.to_lower().contains("completado")
	end_panel.material = _create_end_panel_material(is_success)
	end_layer.add_child(end_panel)

	var title_label := Label.new()
	title_label.text = title_text
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	if title_text.to_lower().contains("fallido"):
		title_label.add_theme_color_override("font_color", Color("#fecaca"))
	else:
		title_label.add_theme_color_override("font_color", Color("#dcfce7"))
	title_label.size = Vector2(500, 45)
	title_label.position = Vector2(0, 35)
	end_panel.add_child(title_label)

	var description_label := Label.new()
	description_label.text = description_text
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 18)
	description_label.add_theme_color_override("font_color", Color("#f1f5f9"))
	description_label.size = Vector2(440, 95)
	description_label.position = Vector2(30, 85)
	end_panel.add_child(description_label)

	retry_button = Button.new()
	retry_button.text = button_text
	retry_button.size = Vector2(230, 48)
	retry_button.position = Vector2(
		(end_panel.size.x - retry_button.size.x) / 2,
		205
	)

	_apply_button_shader(retry_button, end_panel, true)
	retry_button.add_theme_font_size_override("font_size", 17)

	if not retry_button.pressed.is_connected(_on_retry_pressed):
		retry_button.pressed.connect(_on_retry_pressed)

	end_panel.add_child(retry_button)
	
##
# Ejecuta la acción final según el resultado del nivel.
##
func _on_retry_pressed() -> void:
	if end_action == "next":
		_start_level(current_level + 1)
		return

	if end_action == "retry_first":
		game_started = true
		score = 0
		wrong_attempts = 0
		total_words_found = 0
		total_time_remaining = 0
		_start_level(0)
		return

	if end_action == "restart":
		game_started = true
		score = 0
		wrong_attempts = 0
		total_words_found = 0
		total_time_remaining = 0
		_start_level(0)
		return

func _configure_window() -> void:
	var window_size: Vector2i = Vector2i(1450, 850)

	DisplayServer.window_set_size(window_size)
	DisplayServer.window_set_min_size(window_size)

	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var centered_position: Vector2i = Vector2i(
		(screen_size.x - window_size.x) / 2,
		(screen_size.y - window_size.y) / 2
	)

	DisplayServer.window_set_position(centered_position)

##
# Hace que la letra de una celda aparezca y desaparezca lentamente.
##
func _start_letter_fade(button: Button) -> void:
	if letter_tweens.has(button):
		return

	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	var visible_color := Color(1, 1, 1, 1.0)
	var faded_color := Color(1, 1, 1, 0.40)
	tween.tween_method(
		func(value: Color):
			if is_instance_valid(button):
				button.add_theme_color_override("font_color", value),
		visible_color,
		faded_color,
		2.8
	)

	tween.tween_method(
		func(value: Color):
			if is_instance_valid(button):
				button.add_theme_color_override("font_color", value),
		faded_color,
		visible_color,
		2.8
	)

	letter_tweens[button] = tween

##
# Crea el material shader del temporizador según la temática actual.
##
func _create_timer_material_by_theme() -> ShaderMaterial:
	var level_data: Dictionary = WordSearchConfig.LEVELS[current_level]
	var theme: String = String(level_data["theme"])

	var material := ShaderMaterial.new()
	material.shader = timer_theme_shader

	match theme:
		"technology":
			material.set_shader_parameter("text_color", Color("#60a5fa"))
			material.set_shader_parameter("glow_color", Color("#1d4ed8"))
			material.set_shader_parameter("shadow_color", Color("#020617"))
			material.set_shader_parameter("glow_strength", 0.45)
			material.set_shader_parameter("pulse_speed", 1.8)
			material.set_shader_parameter("distortion_strength", 0.003)
			material.set_shader_parameter("scanline_strength", 0.12)

		"education":
			material.set_shader_parameter("text_color", Color("#facc15"))
			material.set_shader_parameter("glow_color", Color("#b7791f"))
			material.set_shader_parameter("shadow_color", Color("#1f1608"))
			material.set_shader_parameter("glow_strength", 0.35)
			material.set_shader_parameter("pulse_speed", 1.1)
			material.set_shader_parameter("distortion_strength", 0.001)
			material.set_shader_parameter("scanline_strength", 0.06)

		"nature":
			material.set_shader_parameter("text_color", Color("#86efac"))
			material.set_shader_parameter("glow_color", Color("#16a34a"))
			material.set_shader_parameter("shadow_color", Color("#052e16"))
			material.set_shader_parameter("glow_strength", 0.38)
			material.set_shader_parameter("pulse_speed", 0.9)
			material.set_shader_parameter("distortion_strength", 0.0015)
			material.set_shader_parameter("scanline_strength", 0.04)

		_:
			material.set_shader_parameter("text_color", Color("#ffffff"))
			material.set_shader_parameter("glow_color", Color("#70a1ff"))
			material.set_shader_parameter("shadow_color", Color("#000000"))
			material.set_shader_parameter("glow_strength", 0.35)
			material.set_shader_parameter("pulse_speed", 1.2)
			material.set_shader_parameter("distortion_strength", 0.001)
			material.set_shader_parameter("scanline_strength", 0.05)

	return material

##
# Crea el material shader para el panel final según éxito o fallo.
##
func _create_end_panel_material(is_success: bool) -> ShaderMaterial:
	var material := ShaderMaterial.new()

	if is_success:
		material.shader = end_success_shader

		var theme: String = String(WordSearchConfig.LEVELS[current_level]["theme"])

		match theme:
			"technology":
				material.set_shader_parameter("base_color", Color("#061426"))
				material.set_shader_parameter("border_color", Color("#2563eb"))
				material.set_shader_parameter("glow_color", Color("#60a5fa"))
				material.set_shader_parameter("shine_color", Color("#93c5fd"))
				material.set_shader_parameter("glow_strength", 0.22)
				material.set_shader_parameter("pulse_speed", 0.85)
				material.set_shader_parameter("shine_strength", 0.05)

			"education":
				material.set_shader_parameter("base_color", Color("#24190b"))
				material.set_shader_parameter("border_color", Color("#b7791f"))
				material.set_shader_parameter("glow_color", Color("#facc15"))
				material.set_shader_parameter("shine_color", Color("#fde68a"))
				material.set_shader_parameter("glow_strength", 0.28)
				material.set_shader_parameter("pulse_speed", 0.9)
				material.set_shader_parameter("pattern_strength", 0.08)

			"nature":
				material.set_shader_parameter("base_color", Color("#052e16"))
				material.set_shader_parameter("border_color", Color("#22c55e"))
				material.set_shader_parameter("glow_color", Color("#86efac"))
				material.set_shader_parameter("shine_color", Color("#bbf7d0"))
				material.set_shader_parameter("glow_strength", 0.30)
				material.set_shader_parameter("pulse_speed", 0.8)
				material.set_shader_parameter("pattern_strength", 0.09)

			_:
				material.set_shader_parameter("base_color", Color("#102418"))
				material.set_shader_parameter("border_color", Color("#2ed573"))
				material.set_shader_parameter("glow_color", Color("#7bed9f"))
				material.set_shader_parameter("shine_color", Color("#ffffff"))
	else:
		material.shader = end_fail_shader
		material.set_shader_parameter("base_color", Color("#26070a"))
		material.set_shader_parameter("border_color", Color("#ef4444"))
		material.set_shader_parameter("glow_color", Color("#f87171"))
		material.set_shader_parameter("warning_color", Color("#fb7185"))
		material.set_shader_parameter("glow_strength", 0.40)
		material.set_shader_parameter("pulse_speed", 2.0)
		material.set_shader_parameter("warning_strength", 0.13)

	return material

##
# Crea un material shader para botones según la temática.
##
func _create_button_material_by_theme(is_retry_button: bool = false) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = button_theme_shader

	var theme: String = String(WordSearchConfig.LEVELS[current_level]["theme"])

	match theme:
		"technology":
			material.set_shader_parameter("base_color", Color("#1d4ed8"))
			material.set_shader_parameter("border_color", Color("#60a5fa"))
			material.set_shader_parameter("glow_color", Color("#2563eb"))
			material.set_shader_parameter("shine_color", Color("#93c5fd"))
			material.set_shader_parameter("glow_strength", 0.32)
			material.set_shader_parameter("pulse_speed", 0.95)
			material.set_shader_parameter("shine_strength", 0.10)
		"education":
			material.set_shader_parameter("base_color", Color("#92400e"))
			material.set_shader_parameter("border_color", Color("#facc15"))
			material.set_shader_parameter("glow_color", Color("#b7791f"))
			material.set_shader_parameter("shine_color", Color("#fde68a"))
			material.set_shader_parameter("glow_strength", 0.32)
			material.set_shader_parameter("pulse_speed", 0.95)
			material.set_shader_parameter("shine_strength", 0.10)

		"nature":
			material.set_shader_parameter("base_color", Color("#166534"))
			material.set_shader_parameter("border_color", Color("#86efac"))
			material.set_shader_parameter("glow_color", Color("#22c55e"))
			material.set_shader_parameter("shine_color", Color("#bbf7d0"))
			material.set_shader_parameter("glow_strength", 0.32)
			material.set_shader_parameter("pulse_speed", 0.95)
			material.set_shader_parameter("shine_strength", 0.10)

		_:
			material.set_shader_parameter("base_color", Color("#3742fa"))
			material.set_shader_parameter("border_color", Color("#70a1ff"))
			material.set_shader_parameter("glow_color", Color("#3742fa"))
			material.set_shader_parameter("shine_color", Color("#ffffff"))
			material.set_shader_parameter("glow_strength", 0.32)
			material.set_shader_parameter("pulse_speed", 0.95)
			material.set_shader_parameter("shine_strength", 0.10)

	if is_retry_button:
		material.set_shader_parameter("glow_strength", 0.24)
		material.set_shader_parameter("pulse_speed", 1.05)

	return material
	

##
# Aplica shader al fondo del botón usando un Panel.
##
func _apply_button_shader(button: Button, parent: Control, is_retry_button: bool = false) -> void:
	if button.has_meta("shader_bg"):
		var old_bg = button.get_meta("shader_bg")
		if is_instance_valid(old_bg):
			old_bg.queue_free()
		button.remove_meta("shader_bg")

	var button_bg := Panel.new()
	button_bg.position = button.position
	button_bg.size = button.size
	button_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color.WHITE
	bg_style.border_color = Color.TRANSPARENT
	bg_style.set_border_width_all(0)
	bg_style.set_corner_radius_all(12)
	bg_style.set_content_margin_all(0)

	button_bg.add_theme_stylebox_override("panel", bg_style)
	button_bg.material = _create_button_material_by_theme(is_retry_button)

	parent.add_child(button_bg)

	if button.get_parent() == parent:
		parent.move_child(button_bg, button.get_index())
		button.move_to_front()

	button.set_meta("shader_bg", button_bg)

	if not is_retry_button:
		validate_button_bg = button_bg

	button.material = null

	var transparent_style := StyleBoxFlat.new()
	transparent_style.bg_color = Color(0, 0, 0, 0)
	transparent_style.border_color = Color(0, 0, 0, 0)
	transparent_style.set_border_width_all(0)
	transparent_style.set_corner_radius_all(12)
	transparent_style.set_content_margin_all(0)

	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("#cbd5e1"))
	button.add_theme_font_size_override("font_size", 19)

	button.add_theme_stylebox_override("normal", transparent_style)
	button.add_theme_stylebox_override("hover", transparent_style)
	button.add_theme_stylebox_override("pressed", transparent_style)
	button.add_theme_stylebox_override("focus", transparent_style)
	button.add_theme_stylebox_override("disabled", transparent_style)

	_connect_button_hover_animation(button)

##
# Agrega animación suave al botón.
##
func _connect_button_hover_animation(button: Button) -> void:
	if not button.mouse_entered.is_connected(_on_button_mouse_entered.bind(button)):
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))

	if not button.mouse_exited.is_connected(_on_button_mouse_exited.bind(button)):
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))


func _on_button_mouse_entered(button: Button) -> void:
	if not is_instance_valid(button):
		return

	var bg: Panel = null

	if button.has_meta("shader_bg"):
		bg = button.get_meta("shader_bg")

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	button.pivot_offset = button.size / 2
	tween.tween_property(button, "scale", Vector2(1.06, 1.06), 0.12)

	if is_instance_valid(bg):
		bg.pivot_offset = bg.size / 2
		tween.parallel().tween_property(bg, "scale", Vector2(1.06, 1.06), 0.12)


func _on_button_mouse_exited(button: Button) -> void:
	if not is_instance_valid(button):
		return

	var bg: Panel = null

	if button.has_meta("shader_bg"):
		bg = button.get_meta("shader_bg")

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	button.pivot_offset = button.size / 2
	tween.tween_property(button, "scale", Vector2.ONE, 0.12)

	if is_instance_valid(bg):
		bg.pivot_offset = bg.size / 2
		tween.parallel().tween_property(bg, "scale", Vector2.ONE, 0.12)

##
# Crea los reproductores de audio:
# - sfx_player para efectos cortos
# - music_player para música de fondo
##
func _create_audio_player() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -4.0
	add_child(sfx_player)

	music_player = AudioStreamPlayer.new()
	music_player.stream = background_music
	music_player.volume_db = -16.0
	music_player.autoplay = false
	add_child(music_player)

	if not music_player.finished.is_connected(_on_background_music_finished):
		music_player.finished.connect(_on_background_music_finished)

##
# Reinicia la música de fondo cuando termina.
##
func _on_background_music_finished() -> void:
	if music_player == null:
		return

	music_player.play()

##
# Reproduce un efecto de sonido.
##
func _play_sfx(sound: AudioStream, volume_db: float = -4.0, pitch: float = 1.0) -> void:
	if sfx_player == null:
		return

	sfx_player.stop()
	sfx_player.stream = sound
	sfx_player.volume_db = volume_db
	sfx_player.pitch_scale = pitch
	sfx_player.play()

func _play_menu_button_sound() -> void:
	_play_sfx(select_sound, -16.0, 0.90)

func _connect_menu_button_sound(button: Button) -> void:
	if not button.pressed.is_connected(_play_menu_button_sound):
		button.pressed.connect(_play_menu_button_sound)

##
# Reproduce la música de fondo.
##
func _play_background_music() -> void:
	if music_player == null:
		return

	if not music_player.playing:
		music_player.play()


##
# Detiene la música de fondo.
##
func _stop_background_music() -> void:
	if music_player == null:
		return

	if music_player.playing:
		music_player.stop()

##
# Crea el material shader del título según la temática actual.
##
func _create_title_material_by_theme() -> ShaderMaterial:
	var level_data: Dictionary = WordSearchConfig.LEVELS[current_level]
	var theme: String = String(level_data["theme"])

	var material := ShaderMaterial.new()
	material.shader = title_theme_shader

	match theme:
		"technology":
			material.set_shader_parameter("text_color", Color("#93c5fd"))
			material.set_shader_parameter("glow_color", Color("#2563eb"))
			material.set_shader_parameter("shadow_color", Color("#020617"))
			material.set_shader_parameter("glow_strength", 0.45)
			material.set_shader_parameter("pulse_speed", 1.8)
			material.set_shader_parameter("distortion_strength", 0.003)
			material.set_shader_parameter("scanline_strength", 0.12)
			material.set_shader_parameter("wave_strength", 0.001)

		"education":
			material.set_shader_parameter("text_color", Color("#fde68a"))
			material.set_shader_parameter("glow_color", Color("#b7791f"))
			material.set_shader_parameter("shadow_color", Color("#1f1608"))
			material.set_shader_parameter("glow_strength", 0.30)
			material.set_shader_parameter("pulse_speed", 0.85)
			material.set_shader_parameter("distortion_strength", 0.0008)
			material.set_shader_parameter("scanline_strength", 0.035)
			material.set_shader_parameter("wave_strength", 0.0006)

		"nature":
			material.set_shader_parameter("text_color", Color("#bbf7d0"))
			material.set_shader_parameter("glow_color", Color("#22c55e"))
			material.set_shader_parameter("shadow_color", Color("#052e16"))
			material.set_shader_parameter("glow_strength", 0.34)
			material.set_shader_parameter("pulse_speed", 0.65)
			material.set_shader_parameter("distortion_strength", 0.0012)
			material.set_shader_parameter("scanline_strength", 0.025)
			material.set_shader_parameter("wave_strength", 0.0025)

		_:
			material.set_shader_parameter("text_color", Color("#ffffff"))
			material.set_shader_parameter("glow_color", Color("#70a1ff"))
			material.set_shader_parameter("shadow_color", Color("#000000"))
			material.set_shader_parameter("glow_strength", 0.35)
			material.set_shader_parameter("pulse_speed", 1.0)
			material.set_shader_parameter("distortion_strength", 0.001)
			material.set_shader_parameter("scanline_strength", 0.05)
			material.set_shader_parameter("wave_strength", 0.001)

	return material

##
# Aplica estilo visual al título según el nivel actual.
##
func _apply_title_theme() -> void:
	if result_label == null:
		return

	var level_data: Dictionary = WordSearchConfig.LEVELS[current_level]
	var theme: String = String(level_data["theme"])

	title_material = _create_title_material_by_theme()
	result_label.material = title_material

	result_label.add_theme_color_override("font_color", Color.WHITE)

	match theme:
		"technology":
			result_label.add_theme_font_size_override("font_size", 31)
			result_label.add_theme_constant_override("outline_size", 2)
			result_label.add_theme_color_override("font_outline_color", Color("#020617"))

		"education":
			result_label.add_theme_font_size_override("font_size", 30)
			result_label.add_theme_constant_override("outline_size", 2)
			result_label.add_theme_color_override("font_outline_color", Color("#3b2f1e"))

		"nature":
			result_label.add_theme_font_size_override("font_size", 31)
			result_label.add_theme_constant_override("outline_size", 2)
			result_label.add_theme_color_override("font_outline_color", Color("#052e16"))

		_:
			result_label.add_theme_font_size_override("font_size", 28)
			result_label.add_theme_constant_override("outline_size", 1)
			result_label.add_theme_color_override("font_outline_color", Color("#000000"))

##
# Devuelve el nombre visible de la temática.
##
func _get_theme_display_name(theme: String) -> String:
	match theme:
		"technology":
			return "Tecnología"
		"education":
			return "Educación"
		"nature":
			return "Naturaleza"
		_:
			return "General"

##
# Devuelve el archivo de palabras según la temática.
##
func _get_words_file_by_theme(theme: String) -> String:
	match theme:
		"technology":
			return WordSearchConfig.WORDS_TECHNOLOGY_FILE

		"education":
			return WordSearchConfig.WORDS_EDUCATION_FILE

		"nature":
			return WordSearchConfig.WORDS_NATURE_FILE

		_:
			push_error("Temática no reconocida: " + theme)
			return WordSearchConfig.WORDS_TECHNOLOGY_FILE


##
# Construye el título principal del nivel.
##
func _get_level_title() -> String:
	var level_data: Dictionary = WordSearchConfig.LEVELS[current_level]

	var level_name: String = String(level_data["name"])
	var theme: String = String(level_data["theme"])
	var theme_name: String = _get_theme_display_name(theme)

	return level_name + " | " + theme_name + " | Sopa de letras"

##
# Asegura que existan GridScroll y GridContainer.
# Si no existen en la escena, los crea automáticamente.
##
func _ensure_grid_nodes() -> void:
	grid_scroll = get_node_or_null("GridScroll")

	if grid_scroll == null:
		grid_scroll = ScrollContainer.new()
		grid_scroll.name = "GridScroll"
		grid_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(grid_scroll)

	grid = grid_scroll.get_node_or_null("GridContainer")

	if grid == null:
		grid = GridContainer.new()
		grid.name = "GridContainer"
		grid_scroll.add_child(grid)

func _get_active_theme() -> String:
	if current_level >= 0 and current_level < WordSearchConfig.LEVELS.size():
		return String(WordSearchConfig.LEVELS[current_level]["theme"])

	return "technology"


func _create_ui_panel_material_by_theme(theme: String, panel_type: String = "default") -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = ui_panel_theme_shader

	match theme:
		"technology":
			material.set_shader_parameter("base_color", Color("#061426"))
			material.set_shader_parameter("border_color", Color("#2563eb"))
			material.set_shader_parameter("glow_color", Color("#1d4ed8"))
			material.set_shader_parameter("accent_color", Color("#60a5fa"))
			material.set_shader_parameter("glow_strength", 0.34)
			material.set_shader_parameter("pulse_speed", 1.30)
			material.set_shader_parameter("pattern_strength", 0.12)
			material.set_shader_parameter("shine_strength", 0.08)

		"education":
			material.set_shader_parameter("base_color", Color("#24190b"))
			material.set_shader_parameter("border_color", Color("#b7791f"))
			material.set_shader_parameter("glow_color", Color("#d6a84f"))
			material.set_shader_parameter("accent_color", Color("#fde68a"))
			material.set_shader_parameter("glow_strength", 0.30)
			material.set_shader_parameter("pulse_speed", 0.85)
			material.set_shader_parameter("pattern_strength", 0.10)
			material.set_shader_parameter("shine_strength", 0.06)

		"nature":
			material.set_shader_parameter("base_color", Color("#052e16"))
			material.set_shader_parameter("border_color", Color("#22c55e"))
			material.set_shader_parameter("glow_color", Color("#16a34a"))
			material.set_shader_parameter("accent_color", Color("#86efac"))
			material.set_shader_parameter("glow_strength", 0.32)
			material.set_shader_parameter("pulse_speed", 0.75)
			material.set_shader_parameter("pattern_strength", 0.10)
			material.set_shader_parameter("shine_strength", 0.06)

		_:
			material.set_shader_parameter("base_color", Color("#111827"))
			material.set_shader_parameter("border_color", Color("#70a1ff"))
			material.set_shader_parameter("glow_color", Color("#3742fa"))
			material.set_shader_parameter("accent_color", Color("#ffffff"))
			material.set_shader_parameter("glow_strength", 0.25)
			material.set_shader_parameter("pulse_speed", 1.0)
			material.set_shader_parameter("pattern_strength", 0.08)
			material.set_shader_parameter("shine_strength", 0.05)

	if panel_type == "feedback":
		material.set_shader_parameter("glow_strength", 0.42)
		material.set_shader_parameter("pattern_strength", 0.14)
		material.set_shader_parameter("shine_strength", 0.10)

	if panel_type == "menu":
		material.set_shader_parameter("glow_strength", 0.38)
		material.set_shader_parameter("shine_strength", 0.11)

	return material


func _create_ui_text_material_by_theme(theme: String, text_type: String = "default") -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = ui_text_theme_shader

	match theme:
		"technology":
			material.set_shader_parameter("text_color", Color("#dbeafe"))
			material.set_shader_parameter("glow_color", Color("#60a5fa"))
			material.set_shader_parameter("shadow_color", Color("#020617"))
			material.set_shader_parameter("glow_strength", 0.35)
			material.set_shader_parameter("pulse_speed", 1.30)
			material.set_shader_parameter("scanline_strength", 0.08)
			material.set_shader_parameter("distortion_strength", 0.0012)

		"education":
			material.set_shader_parameter("text_color", Color("#fef3c7"))
			material.set_shader_parameter("glow_color", Color("#facc15"))
			material.set_shader_parameter("shadow_color", Color("#1f1608"))
			material.set_shader_parameter("glow_strength", 0.28)
			material.set_shader_parameter("pulse_speed", 0.85)
			material.set_shader_parameter("scanline_strength", 0.045)
			material.set_shader_parameter("distortion_strength", 0.0008)

		"nature":
			material.set_shader_parameter("text_color", Color("#dcfce7"))
			material.set_shader_parameter("glow_color", Color("#86efac"))
			material.set_shader_parameter("shadow_color", Color("#052e16"))
			material.set_shader_parameter("glow_strength", 0.30)
			material.set_shader_parameter("pulse_speed", 0.75)
			material.set_shader_parameter("scanline_strength", 0.04)
			material.set_shader_parameter("distortion_strength", 0.0008)

		_:
			material.set_shader_parameter("text_color", Color("#ffffff"))
			material.set_shader_parameter("glow_color", Color("#70a1ff"))
			material.set_shader_parameter("shadow_color", Color("#000000"))
			material.set_shader_parameter("glow_strength", 0.30)
			material.set_shader_parameter("pulse_speed", 1.0)
			material.set_shader_parameter("scanline_strength", 0.05)
			material.set_shader_parameter("distortion_strength", 0.001)

	if text_type == "score":
		material.set_shader_parameter("glow_strength", 0.42)
		material.set_shader_parameter("scanline_strength", 0.06)

	if text_type == "progress":
		material.set_shader_parameter("glow_strength", 0.34)
		material.set_shader_parameter("scanline_strength", 0.045)

	if text_type == "feedback":
		material.set_shader_parameter("glow_strength", 0.24)
		material.set_shader_parameter("scanline_strength", 0.025)
		material.set_shader_parameter("distortion_strength", 0.0004)

	return material

func _reposition_feedback_panel_under_word_panel() -> void:
	if feedback_panel == null:
		return

	if word_panel == null or word_panel.panel == null:
		return

	var screen_size := get_viewport_rect().size
	var margin := 18.0

	var new_y := word_panel.panel.position.y + word_panel.panel.size.y + margin
	var max_y := screen_size.y - feedback_panel.size.y - 35.0

	feedback_panel.position = Vector2(
		35.0,
		min(new_y, max_y)
	)
