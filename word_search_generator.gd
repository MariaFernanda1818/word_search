class_name WordSearchGenerator

##
# Cantidad total de filas que tendrá la sopa de letras.
#
# Este valor se calcula dinámicamente según:
# - cantidad de palabras
# - longitud de la palabra más larga
##
var rows := 0


##
# Cantidad total de columnas que tendrá la sopa de letras.
#
# Generalmente coincide con rows para mantener
# una grilla cuadrada.
##
var cols := 0


##
# Matriz bidimensional que almacena todas las letras
# visibles en la sopa de letras.
##
var letters := []


##
# Diccionario que almacena las posiciones exactas
# donde fue ubicada cada palabra dentro de la grilla.
##
var word_positions := {}


##
# Calcula automáticamente el tamaño ideal de la grilla.
#
# Se basa en:
# - la palabra más larga
# - la cantidad total de palabras
#
# Luego aplica límites mínimo y máximo definidos
# en WordSearchConfig.
#
# @param words Lista de palabras seleccionadas para la partida.
#
# @return Vector2i con:
# - x = columnas
# - y = filas
##
func calculate_grid_size(words: Array) -> Vector2i:
	var longest_word: int = 0

	for word in words:
		longest_word = maxi(longest_word, String(word).length())

	var estimated_size := int(ceil(sqrt(float(words.size() * 12))))

	var final_size := maxi(
		longest_word,
		estimated_size
	)
	rows = final_size
	cols = final_size

	return Vector2i(cols, rows)


##
# Genera completamente la sopa de letras.
#
# Flujo:
# 1. Limpia estructuras anteriores
# 2. Crea matriz vacía
# 3. Ubica cada palabra aleatoriamente
# 4. Rellena espacios vacíos con letras aleatorias
#
# @param words Lista de palabras a ubicar.
#
# @return Matriz final de letras generada.
##
func generate(words: Array) -> Array:
	letters.clear()
	word_positions.clear()

	for row in range(rows):
		var current_row := []

		for col in range(cols):
			current_row.append("")

		letters.append(current_row)

	for word in words:
		_place_word_randomly(word)

	_fill_empty_spaces()

	return letters


##
# Intenta ubicar una palabra de forma aleatoria
# dentro de la grilla.
#
# Soporta:
# - horizontal
# - vertical
# - diagonal
# - en ambas direcciones
#
# Guarda además las posiciones exactas en word_positions.
#
# @param word Palabra que se desea insertar.
##
func _place_word_randomly(word: String) -> void:
	var directions := [
		Vector2i(1, 0),   ## derecha
		Vector2i(0, 1),   ## abajo
		Vector2i(1, 1),   ## diagonal abajo derecha
		Vector2i(-1, 1),  ## diagonal abajo izquierda
		Vector2i(-1, 0),  ## izquierda
		Vector2i(0, -1),  ## arriba
		Vector2i(-1, -1), ## diagonal arriba izquierda
		Vector2i(1, -1)   ## diagonal arriba derecha
	]

	for attempt in range(WordSearchConfig.MAX_ATTEMPTS):
		var direction: Vector2i = directions.pick_random()
		var start_row := randi_range(0, rows - 1)
		var start_col := randi_range(0, cols - 1)

		if _can_place_word(word, start_row, start_col, direction):
			var positions := []

			for i in range(word.length()):
				var row := start_row + direction.y * i
				var col := start_col + direction.x * i

				letters[row][col] = word[i]
				positions.append(Vector2i(col, row))

			word_positions[word] = positions
			return

	print("No se pudo ubicar la palabra: ", word)


##
# Valida si una palabra puede colocarse
# en una posición y dirección específica.
#
# Revisa:
# - que no se salga de la grilla
# - que no sobrescriba letras incompatibles
#
# @param word Palabra a validar.
# @param start_row Fila inicial.
# @param start_col Columna inicial.
# @param direction Dirección de avance.
#
# @return true si puede colocarse, false si no.
##
func _can_place_word(
	word: String,
	start_row: int,
	start_col: int,
	direction: Vector2i
) -> bool:

	for i in range(word.length()):
		var row := start_row + direction.y * i
		var col := start_col + direction.x * i

		if row < 0 or row >= rows:
			return false

		if col < 0 or col >= cols:
			return false

		if letters[row][col] != "" and letters[row][col] != word[i]:
			return false

	return true


##
# Rellena todos los espacios vacíos de la grilla
# con letras aleatorias del alfabeto definido.
#
# Esto completa visualmente la sopa de letras
# una vez ubicadas las palabras reales.
##
func _fill_empty_spaces() -> void:
	for row in range(rows):
		for col in range(cols):
			if letters[row][col] == "":
				letters[row][col] = WordSearchConfig.ALPHABET[
					randi_range(
						0,
						WordSearchConfig.ALPHABET.length() - 1
					)
				]
