extends Node2D

# Nodes
onready var mainMenuAnimationPlayer = $MainMenuAnimationPlayer

func _ready():
	if Utils.get_music_player().stream != Constants.PreloadedMusic.Menu_Music:
		Utils.set_and_play_music(Constants.PreloadedMusic.Menu_Music)
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()
	
	# Start animation
	mainMenuAnimationPlayer.play("FadeIn")
	
	# Sets the text
	get_node("Start Game").set_text(tr("START_GAME"))
	get_node("Settings").set_text(tr("SETTINGS"))
	get_node("Credits").set_text(tr("CREDITS"))
	get_node("Exit to Desktop").set_text(tr("EXIT_TO_DESKTOP"))


# Method to destroy the scene
# Is called when SceneManager changes scene after loading new scene
func destroy_scene():
	pass


func _on_Start_Game_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	
	# Load and save all characters
	Utils.set_all_character_data(FileManager.load_all_character_with_data())
	
	# Navigate to create character screen if no created character are available else to character screen
	var character_list = Utils.get_all_character_data()
	if character_list.empty():
		var transition_data = TransitionData.Menu.new(Constants.CREATE_CHARACTER_SCREEN_PATH)
		Utils.get_scene_manager().transition_to_scene(transition_data)
	else:
		var transition_data = TransitionData.Menu.new(Constants.CHARACTER_SCREEN_PATH)
		Utils.get_scene_manager().transition_to_scene(transition_data)

func _on_Settings_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	Utils.get_main().add_settings()

func _on_Exit_to_Desktop_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	# Stop game
	Utils.stop_game()

func _on_Credits_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	var transition_data = TransitionData.Menu.new(Constants.CREDIT_SCREEN_PATH)
	Utils.get_scene_manager().transition_to_scene(transition_data)
