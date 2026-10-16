extends Area2D

var collected: bool = false


# Inicialización
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	QuestManager.quest_updated.connect(_check_overlap, CONNECT_DEFERRED)

	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	sprite.play("cristal")


# Recoger cristal
func _on_body_entered(body: Node2D) -> void:
	if collected or not body.is_in_group("player"):
		return

	if QuestManager.quest_state != QuestManager.QuestState.ACTIVE:
		return

	collected = true
	QuestManager.collect_crystal()
	queue_free()


# Si la misión empieza con el jugador encima del cristal
func _check_overlap() -> void:
	for body in get_overlapping_bodies():
		_on_body_entered(body)
