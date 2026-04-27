class_name WordListPanel

## Panel principal que contiene la lista de palabras
var panel: Panel

## Contenedor vertical donde se agregan dinámicamente los labels de palabras
var container: VBoxContainer

## Diccionario que relaciona cada palabra con su Label correspondiente
## Ejemplo:
## {
##    "GODOT": Label,
##    "JUEGO": Label
## }
var labels := {}

## Estilo visual personalizado del panel lateral
var panel_style := StyleBoxFlat.new()


##
# Crea el panel lateral de palabras y lo agrega al nodo padre.
#
# @param parent Nodo principal donde se agregará el panel.
# @param words Lista de palabras que deben mostrarse.
# @param screen_size Tamaño actual de la pantalla para calcular alturas dinámicas.
#
func create(parent: Control, words: Array, screen_size: Vector2) -> void:
	_create_style()

	var word_height := 24
	var separation := 6
	var available_height := screen_size.y - 180

	## Calcula altura automática según cantidad de palabras
	var calculated_height := 85 + (words.size() * word_height) + ((words.size() - 1) * separation)

	## Limita la altura mínima y máxima del panel
	var panel_height = clamp(calculated_height, 180, available_height)

	## Crear panel principal
	panel = Panel.new()
	panel.size = Vector2(260, panel_height)
	panel.position = Vector2(50, 155)
	panel.add_theme_stylebox_override("panel", panel_style)
	parent.add_child(panel)

	## Título superior
	var title := Label.new()
	title.text = "Palabras"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#ffffff"))
	title.size = Vector2(260, 35)
	title.position = Vector2(0, 15)
	panel.add_child(title)

	## Scroll para permitir muchas palabras sin romper el layout
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(20, 60)
	scroll.size = Vector2(220, panel_height - 75)
	panel.add_child(scroll)

	## Contenedor vertical interno
	container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(200, 0)
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", separation)
	scroll.add_child(container)

	## Crear cada Label de palabra
	for word in words:
		var label := Label.new()
		label.text = word
		label.custom_minimum_size = Vector2(200, word_height)
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color("#dfe4ea"))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		## Guardar referencia del label para futuras actualizaciones
		labels[word] = label
		container.add_child(label)


##
# Marca visualmente una palabra como encontrada.
#
# Cambia:
# - Color del texto
# - Opacidad
# - Pequeña animación de escala
#
# @param word Palabra encontrada por el jugador.
#
func mark_found(word: String) -> void:
	## Validar existencia de la palabra en el diccionario
	if not labels.has(word):
		return

	var label: Label = labels[word]

	## Mantener el texto y cambiar estilo visual
	label.text = word
	label.add_theme_color_override("font_color", Color("#2ed573"))
	label.modulate = Color(1, 1, 1, 0.65)

	## Animación pequeña para feedback visual
	var tween := label.create_tween()
	label.scale = Vector2.ONE
	tween.tween_property(label, "scale", Vector2(1.15, 1.15), 0.12)
	tween.tween_property(label, "scale", Vector2.ONE, 0.12)


##
# Crea el estilo visual del panel lateral.
#
# Configura:
# - Color de fondo
# - Color de borde
# - Grosor del borde
# - Bordes redondeados
#
func _create_style() -> void:
	panel_style.bg_color = Color("#252b36")
	panel_style.border_color = Color("#70a1ff")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(14)
