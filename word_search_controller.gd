extends Control

##
# Referencia al GridContainer donde se dibuja
# dinámicamente la sopa de letras.
##
@onready var grid_scroll: ScrollContainer = $GridScroll
@onready var grid: GridContainer = $GridScroll/GridContainer

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
	randomize()

	_create_styles()
	_load_random_words()

	var grid_size := generator.calculate_grid_size(words)
	cols = grid_size.x
	rows = grid_size.y
	grid.columns = cols

	_calculate_cell_size()

	letters = generator.generate(words)

	_create_layout()
	word_panel.create(self, words, get_viewport_rect().size)
	_create_grid()

	if not validate_button.pressed.is_connected(_on_validate_pressed):
		validate_button.pressed.connect(_on_validate_pressed)


##
# Carga palabras aleatorias desde el archivo configurado.
#
# Si el archivo no existe o no puede abrirse,
# se cargan palabras por defecto para evitar que el juego falle.
##
func _load_random_words() -> void:
	var file := FileAccess.open(WordSearchConfig.WORDS_FILE, FileAccess.READ)

	if file == null:
		push_error("No se pudo abrir el archivo de palabras")
		words = ["GODOT", "JUEGO", "LETRAS", "SOPA"]
		return

	var all_words := []

	while not file.eof_reached():
		var line := file.get_line().strip_edges().to_upper()

		if line != "" and not all_words.has(line):
			all_words.append(line)

	file.close()
	all_words.shuffle()

	words.clear()

	for i in range(min(WordSearchConfig.WORDS_TO_SELECT, all_words.size())):
		words.append(all_words[i])


##
# Crea y posiciona los elementos principales de la interfaz:
# - título/mensaje
# - grilla
# - botón validar
##
func _create_layout() -> void:
	var screen_size := get_viewport_rect().size
	var grid_width := cols * cell_size + ((cols - 1) * 5)

	result_label.text = "Sopa de letras"
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 26)
	result_label.add_theme_color_override("font_color", Color("#ffffff"))
	result_label.size = Vector2(900, 45)
	result_label.position = Vector2((screen_size.x - result_label.size.x) / 2, 25)

	grid_scroll.position = Vector2(350, 190)
	grid_scroll.size = Vector2(screen_size.x - 390, screen_size.y - 260)
	grid.position = Vector2.ZERO

	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)

	var grid_height := rows * cell_size + ((rows - 1) * 5)

	validate_button.text = "Validar"
	validate_button.size = Vector2(180, 46)

	validate_button.position = Vector2(
		grid_scroll.position.x + (grid_scroll.size.x - validate_button.size.x) / 2,
		grid_scroll.position.y + grid_scroll.size.y + 20
	)
	validate_button.add_theme_font_size_override("font_size", 18)
	validate_button.add_theme_color_override("font_color", Color.WHITE)
	validate_button.add_theme_stylebox_override("normal", button_style)
	validate_button.add_theme_stylebox_override("hover", button_style)
	validate_button.add_theme_stylebox_override("pressed", button_style)

##
# Construye la grilla de botones de la sopa.
##
func _create_grid() -> void:
	for row in range(rows):
		for col in range(cols):
			var button := Button.new()
			button.text = letters[row][col]
			button.custom_minimum_size = Vector2(cell_size, cell_size)
			button.set_meta("row", row)
			button.set_meta("col", col)

			_apply_normal_style(button)

			button.pressed.connect(func(): _on_cell_pressed(button))
			grid.add_child(button)

##
# Maneja la selección y deselección de celdas.
#
# @param button Celda seleccionada
##
func _on_cell_pressed(button: Button) -> void:
	if selected_cells.has(button):
		selected_cells.erase(button)

		if _is_cell_found(button):
			_apply_correct_style(button)
		else:
			_apply_normal_style(button)

		_animate_cell(button, 1.0)
		return

	selected_cells.append(button)
	_apply_selected_style(button)
	_animate_cell(button, 1.15)

##
# Valida si la selección actual corresponde a una palabra.
##
func _on_validate_pressed() -> void:
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
# Compara si dos listas de posiciones son iguales.
#
# @return true si coinciden
##
func _same_positions(selected_positions: Array, word_positions: Array) -> bool:
	if selected_positions.size() != word_positions.size():
		return false

	for position in word_positions:
		if not selected_positions.has(position):
			return false

	return true

##
# Marca una palabra como correcta.
#
# @param word palabra encontrada
##
func _register_correct_word(word: String) -> void:
	found_words.append(word)
	_show_message("Correcto: " + word, Color("#2ed573"))
	word_panel.mark_found(word)

	for cell in selected_cells:
		cell.set_meta("found", true)
		_apply_correct_style(cell)
		_animate_cell(cell, 1.15)

	selected_cells.clear()

##
# Marca una selección incorrecta.
##
func _register_wrong_selection() -> void:
	_show_message("No es una palabra válida", Color("#ff4757"))

	for cell in selected_cells:
		_apply_wrong_style(cell)
		await get_tree().create_timer(0.25).timeout

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
	result_label.add_theme_color_override("font_color", color)

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
	cell_size = 32

	if rows >= 25:
		cell_size = 26

	if rows >= 40:
		cell_size = 22

	if rows >= 60:
		cell_size = 18

	if rows >= 80:
		cell_size = 16

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
	normal_style.bg_color = Color("#2f3542")
	normal_style.border_color = Color("#57606f")
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(10)

	hover_style = normal_style.duplicate()
	hover_style.bg_color = Color("#3d4658")
	hover_style.border_color = Color("#70a1ff")

	selected_style = normal_style.duplicate()
	selected_style.bg_color = Color("#ffa502")
	selected_style.border_color = Color("#ffdd59")

	correct_style = normal_style.duplicate()
	correct_style.bg_color = Color("#2ed573")
	correct_style.border_color = Color("#7bed9f")

	wrong_style = normal_style.duplicate()
	wrong_style.bg_color = Color("#ff4757")
	wrong_style.border_color = Color("#ff6b81")

	button_style.bg_color = Color("#3742fa")
	button_style.set_corner_radius_all(12)

##
# Aplica estilo normal a una celda.
##
func _apply_normal_style(button: Button) -> void:
	button.add_theme_font_size_override("font_size", 21)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", selected_style)

##
# Aplica estilo de selección.
##
func _apply_selected_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", selected_style)
	button.add_theme_stylebox_override("hover", selected_style)
	button.add_theme_stylebox_override("pressed", selected_style)

##
# Aplica estilo de palabra correcta.
##
func _apply_correct_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", correct_style)
	button.add_theme_stylebox_override("hover", correct_style)
	button.add_theme_stylebox_override("pressed", correct_style)

##
# Aplica estilo de error.
##
func _apply_wrong_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", wrong_style)
	button.add_theme_stylebox_override("hover", wrong_style)
	button.add_theme_stylebox_override("pressed", wrong_style)
