extends Node

var sfx_player: AudioStreamPlayer

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

func play_sfx(sound: AudioStream) -> void:
	if sound == null:
		return
	var player := AudioStreamPlayer.new()
	add_child(player)
	
	player.stream = sound
	player.volume_db = 0.0
	player.finished.connect(player.queue_free)
	player.play()
