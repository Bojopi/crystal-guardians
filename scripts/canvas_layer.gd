extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var name_label: Label = $PanelContainer/VBoxContainer/Label
@onready var dialogue_label: Label = $PanelContainer/VBoxContainer/Label2
@onready var continue_button: Button = $PanelContainer/VBoxContainer/Button

@export var desplazamiento_y: float = 120.0

var portrait_rect: TextureRect
var current_dialogues: Array[String] = []
var dialogue_index: int = 0


func _ready() -> void:
	add_to_group("dialogo")
	panel.hide()
	continue_button.text = "Continue..."
	continue_button.pressed.connect(next_dialogue)
	crear_retrato()
	centrar_panel()


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
	panel.custom_minimum_size.x = 520
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.offset_top += desplazamiento_y
	panel.offset_bottom += desplazamiento_y


# Conversación
func show_dialogue(character_name: String, dialogues: Array[String], portrait: Texture2D = null) -> void:
	if dialogues.is_empty():
		return

	current_dialogues.assign(dialogues)
	dialogue_index = 0

	portrait_rect.texture = portrait
	portrait_rect.visible = portrait != null
	name_label.text = character_name
	dialogue_label.text = current_dialogues[dialogue_index]
	panel.show()


func next_dialogue() -> void:
	dialogue_index += 1

	if dialogue_index >= current_dialogues.size():
		close_dialogue()
		return

	dialogue_label.text = current_dialogues[dialogue_index]


func close_dialogue() -> void:
	panel.hide()
	current_dialogues.clear()
	dialogue_index = 0
