
extends Node

@export var min_interval: float = 5.0
@export var max_interval: float = 12.0
@export var transition_duration: float = 1.5

@export var normal_color: Color = Color("#B5BBD0")
@export var dark_color: Color = Color("#252B40")
@export var blackout_color: Color = Color("#080C16")

@onready var canvas_modulate: CanvasModulate = \
	$"../CanvasModulate"

@onready var lighting_timer: Timer = $LightingTimer

var current_tween: Tween


func _ready() -> void:
	randomize()

	canvas_modulate.color = dark_color

	lighting_timer.one_shot = true
	lighting_timer.timeout.connect(
		_on_lighting_timer_timeout
	)

	schedule_next_change()


func schedule_next_change() -> void:
	lighting_timer.wait_time = randf_range(
		min_interval,
		max_interval
	)

	lighting_timer.start()


func _on_lighting_timer_timeout() -> void:
	change_random_lighting()
	schedule_next_change()


func change_random_lighting() -> void:
	var random_value := randi_range(1, 100)
	var target_color: Color

	if random_value <= 40:
		target_color = normal_color
		print("Iluminación: NORMAL")

	elif random_value <= 80:
		target_color = dark_color
		print("Iluminación: OSCURA")

	else:
		target_color = blackout_color
		print("Iluminación: APAGÓN")

	if target_color == blackout_color:
		flicker_lights()
		return

	if current_tween and current_tween.is_running():
		current_tween.kill()

	current_tween = create_tween()

	current_tween.tween_property(
		canvas_modulate,
		"color",
		target_color,
		transition_duration
	)


func flicker_lights() -> void:
	if current_tween and current_tween.is_running():
		current_tween.kill()

	current_tween = create_tween()

	for i in range(3):
		current_tween.tween_property(
			canvas_modulate,
			"color",
			blackout_color,
			0.12
		)

		current_tween.tween_property(
			canvas_modulate,
			"color",
			normal_color,
			0.12
		)

	current_tween.tween_property(
		canvas_modulate,
		"color",
		blackout_color,
		0.5
	)
