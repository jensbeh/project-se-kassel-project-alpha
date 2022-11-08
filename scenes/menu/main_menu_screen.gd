extends Node2D

# Nodes
onready var mainMenuAnimationPlayer = $MainMenuAnimationPlayer

func _ready():
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()
	
	# Start animation
	mainMenuAnimationPlayer.play("FadeIn")
	
	# Sets the text
	get_node("Start Game").set_text(tr("START_GAME"))
	get_node("Settings").set_text(tr("SETTINGS"))
	get_node("Exit to Desktop").set_text(tr("EXIT_TO_DESKTOP"))
	Utils.get_scene_manager().finish_transition()


# Method to destroy the scene
# Is called when SceneManager changes scene after loading new scene
func destroy_scene():
	pass


func _on_Start_Game_pressed():
	Utils.get_sound_player().stream = Constants.PreloadedSounds.Click
	Utils.get_sound_player().play(0.03)
	var transition_data = TransitionData.Menu.new(Constants.CHARACTER_SCREEN_PATH)
	Utils.get_scene_manager().transition_to_scene(transition_data)

func _on_Settings_pressed():
	Utils.get_sound_player().stream = Constants.PreloadedSounds.Click
	Utils.get_sound_player().play(0.03)
	Utils.get_main().add_settings()

func _on_Exit_to_Desktop_pressed():
	Utils.get_sound_player().stream = Constants.PreloadedSounds.Click
	Utils.get_sound_player().play(0.03)
	# Stop game
	Utils.stop_game()
