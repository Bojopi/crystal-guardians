
extends CharacterBody2D

# Configuración
@export var patrol_speed: float = 100.0
@export var chase_speed: float = 100.0
@export var patrol_offset: Vector2 = Vector2(200, 0)
@export var wait_time: float = 1.0
@export var vision_range: float = 180.0
@export var attack_range: float = 40.0
@export var attack_delay: float = 0.5
@export var damage: int = 1

# Referencias
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var player: Node2D
var point_a: Vector2
var point_b: Vector2
var target_point: Vector2
var wait_timer: float = 0.0
var attack_timer: float = 0.0
var attacking: bool = false
var facing: String = "down"


# Inicialización
func _ready() -> void:
	add_to_group("enemy")

	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 10.0

	point_a = global_position
	point_b = global_position + patrol_offset
	target_point = point_b

	player = get_tree().get_first_node_in_group("player")


# Movimiento y detección
func _physics_process(delta: float) -> void:
	if attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	var distance_to_player: float = INF

	if is_instance_valid(player):
		distance_to_player = global_position.distance_to(
			player.global_position
		)

	if distance_to_player <= attack_range:
		velocity = Vector2.ZERO
		_face(player.global_position - global_position)
		attack_timer += delta

		if attack_timer >= attack_delay:
			_attack()
			move_and_slide()
			return

	elif distance_to_player <= vision_range:
		attack_timer = 0.0

		# Calcular una ruta hasta el jugador
		navigation_agent.target_position = player.global_position

		if not navigation_agent.is_navigation_finished():
			var next_position: Vector2 = (
				navigation_agent.get_next_path_position()
			)

			var chase_direction: Vector2 = (
				global_position.direction_to(next_position)
			)

			velocity = chase_direction * chase_speed
			_face(chase_direction)
		else:
			velocity = Vector2.ZERO

	else:
		attack_timer = 0.0
		_patrol(delta)

	move_and_slide()

	if not attacking:
		_update_animation()


# Patrulla
func _patrol(delta: float) -> void:
	if wait_timer > 0.0:
		wait_timer -= delta
		velocity = Vector2.ZERO
		return

	if global_position.distance_to(target_point) < 4.0:
		target_point = point_a if target_point == point_b else point_b
		wait_timer = wait_time
		velocity = Vector2.ZERO
		return

	var patrol_direction: Vector2 = (
		target_point - global_position
	).normalized()

	velocity = patrol_direction * patrol_speed
	_face(patrol_direction)


# Ataque
func _attack() -> void:
	attacking = true
	attack_timer = 0.0
	velocity = Vector2.ZERO

	var attack_animation: String = "attack_" + facing

	if animated_sprite.sprite_frames.has_animation(attack_animation):
		animated_sprite.play(attack_animation)

		var frames: int = animated_sprite.sprite_frames.get_frame_count(
			attack_animation
		)
		var fps: float = animated_sprite.sprite_frames.get_animation_speed(
			attack_animation
		)

		var duration: float = 0.4

		if fps > 0.0:
			duration = float(frames) / fps

		await get_tree().create_timer(duration).timeout

		if is_instance_valid(player):
			var distance: float = global_position.distance_to(
				player.global_position
			)

			if distance <= attack_range * 1.5:
				player.take_damage(damage)
	else:
		push_warning("No existe la animación: " + attack_animation)
		await get_tree().create_timer(0.4).timeout

	attacking = false


# Dirección
func _face(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		facing = "right" if direction.x > 0 else "left"
	else:
		facing = "down" if direction.y > 0 else "up"


# Animaciones de movimiento
func _update_animation() -> void:
	if velocity == Vector2.ZERO:
		animated_sprite.stop()
	else:
		animated_sprite.play(facing)
