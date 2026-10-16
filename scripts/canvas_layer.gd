class_name DialogueCanvas
extends CanvasLayer

signal finished(answer: int)

const ANSWER_CANCELLED: int = -2
const ANSWER_NONE: int = -1
const ANSWER_NO: int = 0
const ANSWER_YES: int = 1

@onready var panel: PanelContainer = $PanelContainer
@onready var name_label: Label = $PanelContainer/VBoxContainer/Label
@onready var dialogue_label: Label = $PanelContainer/VBoxContainer/Label2
@onready var continue_button: Button = $PanelContainer/VBoxContainer/Button

@export var desplazamiento_y: float = 120.0

var portrait_rect: TextureRect
var choice_box: HBoxContainer
var current_dialogues: Array[String] = []
var dialogue_index: int = 0
var ask_at_end: bool = false
var is_open: bool = false


func _ready() -> void:
	add_to_group("dialogo")
	panel.hide()
	continue_button.text = "Continuar"
	continue_button.pressed.connect(next_dialogue)
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.custom_minimum_size.x = 380
	crear_opciones()
	crear_retrato()
	centrar_panel()


# Opciones Sí / No
func crear_opciones() -> void:
	choice_box = HBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 12)
	continue_button.get_parent().add_child(choice_box)

	for opcion in [["Sí", ANSWER_YES], ["No", ANSWER_NO]]:
		var boton := Button.new()
		boton.text = opcion[0]
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.pressed.connect(_on_choice_pressed.bind(opcion[1]))
		choice_box.add_child(boton)

	choice_box.hide()


# Retrato
func crear_retrato() -> void:
	var contenido := HBoxContainer.new()
	contenido.add_theme_constant_override("separation", 12)
	panel.add_child(contenido)

	portrait_rect = TextureRect.new()
	portrait_rect.custom_minimum_size = Vector2(104, 104)
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	contenido.add_child(portrait_rect)

	var textos := $PanelContainer/VBoxContainer
	textos.reparent(contenido)
	textos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textos.size_flags_vertical = Control.SIZE_SHRINK_CENTER


# Posición
func centrar_panel() -> void:
	panel.custom_minimum_size.x = 540
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.offset_top += desplazamiento_y
	panel.offset_bottom += desplazamiento_y


# Conversación
func show_dialogue(character_name: String, dialogues: Array[String], portrait: Texture2D = null, ask: bool = false) -> void:
	if dialogues.is_empty() or is_open:
		return

	current_dialogues.assign(dialogues)
	dialogue_index = 0
	ask_at_end = ask
	is_open = true

	portrait_rect.texture = portrait
	portrait_rect.visible = portrait != null
	name_label.text = character_name
	panel.show()
	_show_line()


func _show_line() -> void:
	dialogue_label.text = current_dialogues[dialogue_index]

	var is_last := dialogue_index == current_dialogues.size() - 1
	var asking := is_last and ask_at_end

	continue_button.visible = not asking
	choice_box.visible = asking

	if asking:
		choice_box.get_child(0).grab_focus()
	else:
		continue_button.grab_focus()


func next_dialogue() -> void:
	if not is_open:
		return

	var is_last := dialogue_index == current_dialogues.size() - 1
	if is_last and ask_at_end:
		return

	dialogue_index += 1

	if dialogue_index >= current_dialogues.size():
		_finish(ANSWER_NONE)
		return

	_show_line()


func _on_choice_pressed(answer: int) -> void:
	if is_open:
		_finish(answer)


func close_dialogue() -> void:
	if is_open:
		_finish(ANSWER_CANCELLED)


func _finish(answer: int) -> void:
	panel.hide()
	choice_box.hide()
	current_dialogues.clear()
	dialogue_index = 0
	is_open = false
	finished.emit(answer)
