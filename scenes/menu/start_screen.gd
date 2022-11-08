extends Node2D


# Constants
const MAIN_MENU_SCREEN = preload("res://scenes/menu/MainMenuScreen.tscn")

# Nodes
onready var animationPlayer = $CanvasLayer/AnimationPlayer

# Variables
var main_menu_screen
var thread
var lang
var save_setting = {
		language = "en",
		sound = 0,
		music = 0
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	# Start animation
	animationPlayer.play("FadeIn")
	
	# load settings
	var save_settings = File.new()
	if save_settings.file_exists(Constants.SAVE_SETTINGS_PATH):
		save_settings.open(Constants.SAVE_SETTINGS_PATH, File.READ)
		save_setting = parse_json(save_settings.get_as_text())
		save_settings.close()
		lang = save_setting.language
	else:
		var save_game = File.new()
		save_game.open(Constants.SAVE_SETTINGS_PATH, File.WRITE)
		save_game.store_line(to_json(save_setting))
		save_game.close()
		lang = "en"
		save_setting.sound = 0
		save_setting.music = 0
	# check if not saved
	if !save_setting.has("music"):
		save_setting.music = 0
	if !save_setting.has("sound"):
		save_setting.sound = 0
	# Sets the Langauge and the sound/music volume
	Utils.set_language(lang)
	Utils.set_music_volume(save_setting.music)
	AudioServer.set_bus_volume_db(1, save_setting.music)
	Utils.set_sound_volume(save_setting.sound)
	AudioServer.set_bus_volume_db(2, save_setting.sound)
	TranslationServer.set_locale(lang)
	Utils.get_music_player().play()
	
	# init variables
	main_menu_screen = MAIN_MENU_SCREEN.instance()
	
	# Setup scene in background
	thread = Thread.new()
	thread.start(self, "_preload_game_in_background")


# Method to setup this scene with a thread in background
func _preload_game_in_background():
	Utils.preload_game()
	
	# Preload done
	call_deferred("_on_preload_game_done")


# Method is called when thread is done and the scene is setup
func _on_preload_game_done():
	thread.wait_to_finish()
	
	# Loading is done -> fade out
	animationPlayer.play("FadeOut")


# Method is called from fadeout animation when it is finished to change scene to main menu
func on_fade_out_screen_finished():
	# Change to main_menu_screen
	Utils.get_scene_manager().without_transition_to_scene(main_menu_screen)


# Method to destroy the scene
# Is called when SceneManager changes scene
func destroy_scene():
	main_menu_screen = null
