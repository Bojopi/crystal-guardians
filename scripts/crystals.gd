
extends Label

var cristales: int = 0

func _ready() -> void:
	add_to_group("hud")
	actualizar_texto()

func sumar_cristal() -> void:
	cristales += 1
	actualizar_texto()

func actualizar_texto() -> void:
	text = "Cristales: " + str(cristales)
