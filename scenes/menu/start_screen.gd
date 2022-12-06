extends Node2D

# Nodes
onready var animationPlayer = $CanvasLayer/AnimationPlayer

# Variables
var preload_game_thread


# Called when the node enters the scene tree for the first time.
func _ready():
	# Start animation
	animationPlayer.play("FadeIn")
	
	var _error = PreloadService.connect("preload_first_done", self, "_on_preload_first_done")


# Method is called when game is preload first done
func _on_preload_first_done():
	# Loading is done -> fade out
	animationPlayer.play("FadeOut")


# Method is called from fadeout animation when it is finished to change scene to main menu
func on_fade_out_screen_finished():
	# Change to main_menu_screen
	Utils.get_scene_manager().without_transition_to_scene(Constants.MAIN_MENU_PATH)


# Method to destroy the scene
# Is called when SceneManager changes scene
func destroy_scene():
#	# Stop preloading if its still running -> in case game is closed while loading
#	if preload_game_thread.is_active():
#		Utils.stop_preload_game()
#		if preload_game_thread.is_active():
#			preload_game_thread.wait_to_finish()
	
	
	# Disconnect signals
	PreloadService.disconnect("preload_first_done", self, "_on_preload_first_done")
