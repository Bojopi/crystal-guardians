extends Area2D
@export var crystal_id: String = ""
@export var crystal_audio: AudioStream
var was_collected: bool = false

const COLLECT_EFFECT = preload("res://scenes/crystal_collect_effect.tscn")

func _ready() -> void:
	if crystal_id in QuestManager.collected_crystal_ids:
		queue_free()
		return
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if was_collected:
		return

	if not body.is_in_group("player"):
		return
	if QuestManager.collect_crystal(crystal_id):
		was_collected = true
		queue_free()
		var effect = COLLECT_EFFECT.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position
		AudioManager.play_sfx(crystal_audio)
