extends Node2D



func _ready():
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()


func _on_Start_Game_pressed():
	var transition_data = TransitionData.Menu.new(Constants.CHARACTER_SCREEN_PATH)
	Utils.get_scene_manager().transition_to_scene(transition_data)

func _on_Settings_pressed():
	pass

func _on_Exit_to_Desktop_pressed():
	get_tree().quit()