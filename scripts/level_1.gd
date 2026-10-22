extends Node2D

var crystals_collected: int = 0
var total_crystals: int = 0

@onready var player = $player
@onready var game_hud = $GameHUD


func _ready() -> void:
	var crystals := $crystals.get_children()

	total_crystals = crystals.size()
	player.health_changed.connect(game_hud.update_health)
	game_hud.update_health(player.health, player.max_health)
	
	# Primero preparar el estado de misión del nivel.
	QuestManager.reset_quest()

	# Después restaurar la partida, si existe.
	restore_saved_game.call_deferred()
	
	player.set_flashlight_enabled(false)

func _on_crystal_collected() -> void:
	crystals_collected += 1

	if crystals_collected >= total_crystals:
		print("¡Todos los cristales recolectados!")

func save_current_game() -> void:
	var current_level: String = scene_file_path
	SaveManager.save_game(
		player,
		current_level
	)

func restore_saved_game() -> void:
	SaveManager.apply_saved_data(player)
