extends Node2D
@onready var particles: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	particles.one_shot = true
	particles.emitting = true
	
	await get_tree().create_timer(1.2).timeout
	queue_free()
