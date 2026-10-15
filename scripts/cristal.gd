
extends Area2D

# Inicialización
func _ready() -> void:
	body_entered.connect(_on_body_entered)

	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	sprite.play("cristal")


# Recoger cristal
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var contador = get_tree().get_first_node_in_group("hud")

		if contador and contador.has_method("sumar_cristal"):
			contador.sumar_cristal()

		queue_free()
