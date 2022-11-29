extends Node2D

# Nodes
onready var animationPlayer = $CanvasLayer/AnimationPlayer

# Variables
var preload_game_thread
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
	if float(save_setting.music) == -40:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
	Utils.set_sound_volume(save_setting.sound)
	AudioServer.set_bus_volume_db(2, save_setting.sound)
	if float(save_setting.sound) == -40:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
	TranslationServer.set_locale(lang)
	Utils.set_and_play_music(Constants.PreloadedMusic.Menu_Music)
	
	# Setup scene in background
	preload_game_thread = Thread.new()
	preload_game_thread.start(self, "_preload_game_in_background")


# Method to preload game with a thread in background
func _preload_game_in_background():
	Utils.preload_game()
	
	# Preload done
	call_deferred("_on_preload_game_done")


# Method is called when thread is done and the game is preloaded
func _on_preload_game_done():
	if preload_game_thread.is_active():
		preload_game_thread.wait_to_finish()
	
	# Loading is done -> fade out
	animationPlayer.play("FadeOut")


# Method is called from fadeout animation when it is finished to change scene to main menu
func on_fade_out_screen_finished():
	# Change to main_menu_screen
	Utils.get_scene_manager().without_transition_to_scene(Constants.MAIN_MENU_PATH)


# Method to destroy the scene
# Is called when SceneManager changes scene
func destroy_scene():
	# Stop preloading if its still running -> in case game is closed while loading
	if preload_game_thread.is_active():
		Utils.stop_preload_game()
		if preload_game_thread.is_active():
			preload_game_thread.wait_to_finish()
