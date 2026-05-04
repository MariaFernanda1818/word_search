class_name WordListPanel

## Shader del panel de palabras
var word_panel_shader := preload("res://shaders/word_panel_theme.gdshader")

## Material dinámico del panel
var panel_material: ShaderMaterial

## Panel principal que contiene la lista de palabras
var panel: Panel

## Contenedor vertical donde se agregan dinámicamente los labels de palabras
var container: VBoxContainer

## Diccionario que relaciona cada palabra con su Label correspondiente
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
func create(parent: Control, words: Array, screen_size: Vector2, theme: String = "technology") -> void:
	_create_style()
	_create_panel_shader(theme)

	var word_height := 24
	var separation := 6
	var available_height := screen_size.y - 180
	var calculated_height := 85 + (words.size() * word_height) + ((words.size() - 1) * separation)

	var panel_height = clamp(calculated_height, 180, available_height)

	panel = Panel.new()
	panel.size = Vector2(260, panel_height)
	panel.position = Vector2(50, 155)
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.material = panel_material
	parent.add_child(panel)

	var title := Label.new()
	title.text = "Palabras"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", _get_text_color_by_theme(theme))
	title.size = Vector2(260, 35)
	title.position = Vector2(0, 15)
	panel.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(20, 60)
	scroll.size = Vector2(220, panel_height - 75)
	panel.add_child(scroll)

	container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(200, 0)
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", separation)
	scroll.add_child(container)

	for word in words:
		var label := Label.new()
		label.text = word
		label.custom_minimum_size = Vector2(200, word_height)
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", _get_text_color_by_theme(theme))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

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
	if not labels.has(word):
		return

	var label: Label = labels[word]

	label.text = "✓ " + word
	label.add_theme_color_override("font_color", Color("#2ed573"))
	label.modulate = Color(1, 1, 1, 0.65)

	var tween := label.create_tween()
	label.scale = Vector2.ONE
	tween.tween_property(label, "scale", Vector2(1.15, 1.15), 0.12)
	tween.tween_property(label, "scale", Vector2.ONE, 0.12)

func _get_text_color_by_theme(theme: String) -> Color:
	match theme:
		"technology":
			return Color("#dbeafe")
		"education":
			return Color("#fef3c7")
		"nature":
			return Color("#dcfce7")
		_:
			return Color("#ffffff")

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
	panel_style.bg_color = Color(1, 1, 1, 0.08)
	panel_style.border_color = Color(1, 1, 1, 0.18)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(14)
	

##
# Crea el shader visual del panel de palabras según la temática.
##
func _create_panel_shader(theme: String) -> void:
	panel_material = ShaderMaterial.new()
	panel_material.shader = word_panel_shader

	match theme:
		"technology":
			panel_material.set_shader_parameter("base_color", Color("#08111f"))
			panel_material.set_shader_parameter("border_color", Color("#2563eb"))
			panel_material.set_shader_parameter("glow_color", Color("#1d4ed8"))
			panel_material.set_shader_parameter("accent_color", Color("#60a5fa"))
			panel_material.set_shader_parameter("glow_strength", 0.28)
			panel_material.set_shader_parameter("pulse_speed", 1.4)
			panel_material.set_shader_parameter("pattern_strength", 0.10)

		"education":
			panel_material.set_shader_parameter("base_color", Color("#24190b"))
			panel_material.set_shader_parameter("border_color", Color("#b7791f"))
			panel_material.set_shader_parameter("glow_color", Color("#d6a84f"))
			panel_material.set_shader_parameter("accent_color", Color("#fde68a"))
			panel_material.set_shader_parameter("glow_strength", 0.24)
			panel_material.set_shader_parameter("pulse_speed", 0.8)
			panel_material.set_shader_parameter("pattern_strength", 0.08)

		"nature":
			panel_material.set_shader_parameter("base_color", Color("#071f13"))
			panel_material.set_shader_parameter("border_color", Color("#22c55e"))
			panel_material.set_shader_parameter("glow_color", Color("#16a34a"))
			panel_material.set_shader_parameter("accent_color", Color("#86efac"))
			panel_material.set_shader_parameter("glow_strength", 0.25)
			panel_material.set_shader_parameter("pulse_speed", 0.7)
			panel_material.set_shader_parameter("pattern_strength", 0.09)

		_:
			panel_material.set_shader_parameter("base_color", Color("#252b36"))
			panel_material.set_shader_parameter("border_color", Color("#70a1ff"))
			panel_material.set_shader_parameter("glow_color", Color("#3742fa"))
			panel_material.set_shader_parameter("accent_color", Color("#ffffff"))
			panel_material.set_shader_parameter("glow_strength", 0.25)
			panel_material.set_shader_parameter("pulse_speed", 1.0)
			panel_material.set_shader_parameter("pattern_strength", 0.08)
