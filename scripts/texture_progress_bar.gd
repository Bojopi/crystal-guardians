extends TextureProgressBar

# Configuración
const TOTAL_CORAZONES: int = 4

var jugador: Node = null


# Inicialización
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("health_bar")

	min_value = 0
	max_value = TOTAL_CORAZONES
	step = 1

	jugador = get_tree().get_first_node_in_group("player")
	actualizar_corazones()

# Actualización de corazones
func _process(_delta: float) -> void:
	if not is_instance_valid(jugador):
		jugador = get_tree().get_first_node_in_group("player")

	actualizar_corazones()


# Control de vida
func actualizar_corazones() -> void:
	if not is_instance_valid(jugador):
		return

	var vida_actual: int = int(jugador.get("health"))

	value = clampi(vida_actual, 0, TOTAL_CORAZONES)

	# Ocultar todos los corazones cuando la vida llegue a cero
	visible = vida_actual > 0
