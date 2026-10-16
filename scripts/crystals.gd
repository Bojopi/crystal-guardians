extends Label


func _ready() -> void:
	add_to_group("hud")
	QuestManager.quest_updated.connect(actualizar_texto)
	actualizar_texto()


func actualizar_texto() -> void:
	text = "Cristales: %d/%d" % [
		QuestManager.collected_crystals,
		QuestManager.required_crystals
	]
