extends Area2D

@export var nombre_personaje: String = "Han Solo"
@export var dialogos: Array[String] = [
	"welcon sir."
]

@export var retrato: Texture2D

var canvas_layer: Node


func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# Se busca aquí porque el CanvasLayer se registra en el grupo después de que el NPC inicia
	canvas_layer = get_tree().get_first_node_in_group("dialogo")

	if canvas_layer == null:
		print("ERROR: No encuentro CanvasLayer en el grupo dialogo")
		return

	canvas_layer.show_dialogue(nombre_personaje, dialogos, retrato)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and canvas_layer != null:
		canvas_layer.close_dialogue()
