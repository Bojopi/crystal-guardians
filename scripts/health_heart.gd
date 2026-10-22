extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@export var heal_amount: int = 25
@export var lifetime: float = 20.0

var collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	start_lifetime()
	animate_heart()



func _on_body_entered(body: Node2D) -> void:
	print("Objeto detectado: ", body.name)

	if collected:
		return

	if not body.is_in_group("player"):
		return

	if not body.has_method("heal"):
		return

	if body.health >= body.max_health:
		print("El jugador ya tiene la vida completa")
		return

	collected = true

	body.heal(heal_amount)

	print("Corazón recogido correctamente")

	queue_free()



func start_lifetime() -> void:
	await get_tree().create_timer(lifetime).timeout

	if is_instance_valid(self):
		queue_free()


func animate_heart() -> void:
	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(
		sprite,
		"position:y",
		-8.0,
		0.7
	).set_trans(Tween.TRANS_SINE)

	tween.tween_property(
		sprite,
		"position:y",
		0.0,
		0.7
	).set_trans(Tween.TRANS_SINE)
