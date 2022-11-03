extends Node2D


# Constants
const MAIN_MENU_SCREEN = preload("res://scenes/menu/MainMenuScreen.tscn")

# Nodes
onready var animationPlayer = $CanvasLayer/AnimationPlayer

# Variables
var main_menu_screen
var thread


# Called when the node enters the scene tree for the first time.
func _ready():
	# Start animation
	animationPlayer.play("FadeIn")
	
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
