class_name WordSearchConfig

##
# Cantidad máxima de palabras que se seleccionarán
# aleatoriamente desde el archivo words.txt
#
# Ejemplo:
# Si el archivo tiene 100 palabras y el valor es 5,
# solo se usarán 5 palabras por partida.
##
const WORDS_TO_SELECT := 30


##
# Ruta del archivo de texto que contiene todas las palabras
# disponibles para la sopa de letras.
#
# Cada línea del archivo representa una palabra.
#
# Ejemplo:
# GODOT
# JUEGO
# PROGRAMA
# CODIGO
##
const WORDS_FILE := "res://words.txt"


##
# Conjunto de letras usadas para rellenar los espacios vacíos
# de la sopa de letras una vez que se ubican las palabras reales.
#
# Estas letras se seleccionan aleatoriamente.
##
const ALPHABET := "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ"


##
# Número máximo de intentos permitidos para ubicar
# una palabra dentro de la sopa de letras.
#
# Si después de esta cantidad no se logra ubicar,
# se omite la palabra y se muestra un mensaje en consola.
##
const MAX_ATTEMPTS := 200
