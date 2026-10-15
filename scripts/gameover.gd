extends Label


# Inicialización
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_over")

	text = "¡GAME OVER!"
	visible = false

	# Mostrar el mensaje centrado en la pantalla
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	add_theme_font_size_override("font_size", 48)


# Mostrar Game Over
func mostrar_game_over() -> void:
	text = "¡PERDISTE!"
	visible = true
	show()
	print("Mensaje GAME OVER mostrado")
