
extends Node2D

@export var heart_scene: PackedScene

@export var min_spawn_time: float = 8.0
@export var max_spawn_time: float = 15.0
@export var max_hearts: int = 3

@onready var spawn_points: Node2D = $SpawnPoints
@onready var spawn_timer: Timer = $SpawnTimer

var active_hearts: Array[Node2D] = []


func _ready() -> void:
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	schedule_next_spawn()


func schedule_next_spawn() -> void:
	spawn_timer.wait_time = randf_range(
		min_spawn_time,
		max_spawn_time
	)

	spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	spawn_heart()
	schedule_next_spawn()


func spawn_heart() -> void:
	if heart_scene == null:
		push_warning("No se asignó la escena del corazón")
		return

	# Limpiar referencias a corazones eliminados
	active_hearts = active_hearts.filter(
		func(heart): return is_instance_valid(heart)
	)

	if active_hearts.size() >= max_hearts:
		return

	var points := spawn_points.get_children()

	if points.is_empty():
		return

	var available_points: Array[Node] = []

	for point in points:
		var occupied := false

		for heart in active_hearts:
			if heart.global_position.distance_to(
				point.global_position
			) < 16.0:
				occupied = true
				break

		if not occupied:
			available_points.append(point)

	if available_points.is_empty():
		return

	var random_point: Node2D = available_points.pick_random()

	var heart := heart_scene.instantiate() as Node2D

	if heart == null:
		return

	get_tree().current_scene.add_child(heart)

	heart.global_position = random_point.global_position

	active_hearts.append(heart)

	print("Corazón generado en: ", heart.global_position)
