
extends Camera2D

@export var shake_strength: float = 8.0
@export var shake_duration: float = 0.25

var shake_time: float = 0.0


func _process(delta: float) -> void:
	if shake_time > 0.0:
		shake_time = maxf(shake_time - delta, 0.0)

		var intensity := shake_time / shake_duration

		offset = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * shake_strength * intensity
	else:
		offset = Vector2.ZERO


func shake(
	strength: float = 8.0,
	duration: float = 0.25
	) -> void:
	shake_strength = strength
	shake_duration = maxf(duration, 0.01)
	shake_time = shake_duration
