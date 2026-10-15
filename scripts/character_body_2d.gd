extends CharacterBody2D

# Configuración
@export var speed: float = 220.0
@export var max_health: int = 4

var health: int = 4
var hurt: bool = false

# Referencias
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


# Inicialización
func _ready() -> void:
	add_to_group("player")
	health = max_health


# Movimiento
func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed
	move_and_slide()

	actualizar_animacion(direction)


# Animaciones
func actualizar_animacion(direction: Vector2) -> void:
	if hurt:
		return

	if direction == Vector2.ZERO:
		animated_sprite.stop()
		return

	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("right" if direction.x > 0 else "left")
	else:
		animated_sprite.play("down" if direction.y > 0 else "up")


func reproducir_damage() -> void:
	var frames := animated_sprite.sprite_frames
	if hurt or not frames.has_animation("damage"):
		return

	hurt = true
	animated_sprite.play("damage")

	var duration := frames.get_frame_count("damage") / frames.get_animation_speed("damage")
	await get_tree().create_timer(duration).timeout
	hurt = false


# Vida y daño
func take_damage(amount: int) -> void:
	if health <= 0:
		return

	health = maxi(health - amount, 0)
	print("Vida del jugador: ", health)

	# Actualizar los corazones antes de pausar
	get_tree().call_group("health_bar", "actualizar_corazones")

	if health == 0:
		get_tree().call_group("gameover", "mostrar_gameover")
		get_tree().paused = true
	else:
		reproducir_damage()
