class_name WordSearchConfig



const WORDS_TECHNOLOGY_FILE := "res://words/tecnologia.txt"
const WORDS_EDUCATION_FILE := "res://words/educacion.txt"
const WORDS_NATURE_FILE := "res://words/naturaleza.txt"


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

##
# Configuración de los 3 niveles.
# Puedes cambiar cantidad de palabras y tiempo por nivel.
##
const LEVELS := [
	{
		"name": "Nivel 1",
		"words": 5,
		"time": 180,
		"cols": 15,
		"rows": 9,
		"theme": "technology"
	},
	{
		"name": "Nivel 2",
		"words": 8,
		"time": 200,
		"cols": 17,
		"rows": 10,
		"theme": "education"
	},
	{
		"name": "Nivel 3",
		"words": 10,
		"time": 220,
		"cols": 19,
		"rows": 11,
		"theme": "nature"
	}
]
