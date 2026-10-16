extends Area2D

@export var nombre_personaje: String = "Han Solo"
@export var retrato: Texture2D

const NUMEROS: Array[String] = ["cero", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve", "diez"]

var player_in_range: bool = false
var talking: bool = false
var canvas_layer: DialogueCanvas


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# Proximidad
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_in_range = false

	if talking and canvas_layer != null:
		canvas_layer.close_dialogue()


# Interacción con E
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or event.is_echo():
		return

	if not player_in_range or talking:
		return

	get_viewport().set_input_as_handled()
	_talk()


func _talk() -> void:
	canvas_layer = get_tree().get_first_node_in_group("dialogo") as DialogueCanvas

	if canvas_layer == null:
		print("ERROR: No encuentro el CanvasLayer del diálogo (grupo dialogo)")
		return

	talking = true

	var state := QuestManager.quest_state

	if state == QuestManager.QuestState.NOT_STARTED:
		await _offer_quest()
	elif state == QuestManager.QuestState.ACTIVE:
		await _report_progress()
	elif state == QuestManager.QuestState.READY_TO_DELIVER:
		await _deliver_quest()
	else:
		await _say_completed()

	talking = false


# Diálogos
func _say(lines: Array[String], ask: bool = false) -> int:
	canvas_layer.show_dialogue(nombre_personaje, lines, retrato, ask)
	var answer: int = await canvas_layer.finished
	return answer


func _offer_quest() -> void:
	var answer: int = await _say(["Hola, bienvenido, señor.", "¿Podrías ayudarme?"], true)

	if answer == DialogueCanvas.ANSWER_CANCELLED:
		return

	if answer == DialogueCanvas.ANSWER_NO:
		await _say(["Entiendo. Si cambias de opinión, estaré aquí."])
		return

	var explanation: int = await _say(["Unos bandidos han robado mis cristales y los han dispersado por todo el mapa. Necesito recuperarlos. ¿Podrías ayudarme a encontrarlos?"])

	if explanation == DialogueCanvas.ANSWER_CANCELLED:
		return

	QuestManager.start_quest()


func _report_progress() -> void:
	var collected := QuestManager.collected_crystals
	var required := QuestManager.required_crystals
	var missing := required - collected
	var line: String

	if collected == 0:
		line = "Todavía no has encontrado ningún cristal. Necesitamos recuperar los %s." % _numero(required)
	elif missing == 1:
		line = "Veo que tienes %d de los %d cristales. ¡Ya casi lo conseguimos! Solo falta %d." % [collected, required, missing]
	else:
		line = "Veo que tienes %d de los %d cristales. ¡Buen trabajo! Todavía nos faltan %d." % [collected, required, missing]

	await _say([line])


func _deliver_quest() -> void:
	var answer: int = await _say([
		"¡Perfecto, muchas gracias por ayudarme! Has recuperado todos los cristales a tiempo. Ahora podemos activar el portal.",
		"Gracias por tu gran ayuda. El portal está listo para ser utilizado. ¡Buen viaje!"
	])

	if answer == DialogueCanvas.ANSWER_CANCELLED:
		return

	QuestManager.complete_quest()


func _say_completed() -> void:
	await _say(["Ya me ayudaste a recuperar todos los cristales. El portal está listo para ser utilizado. ¡Buen viaje!"])


func _numero(n: int) -> String:
	if n >= 0 and n < NUMEROS.size():
		return NUMEROS[n]
	return str(n)
