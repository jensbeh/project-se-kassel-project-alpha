extends CanvasLayer


func _ready():
	get_node("Exit Game").set_text(tr("EXIT_GAME"))
	get_node("Back to Main Menu").set_text(tr("BACK_TO_MAIN_MENU"))
	get_node("Back to Game").set_text(tr("BACK_TO_GAME"))
	get_node("Settings").set_text(tr("SETTINGS"))
	set_layer(2)


# Close game menu and set playermovemnt true
func _on_Back_to_Game_pressed():
	Utils.get_game_menu().queue_free()
	Utils.get_current_player().set_movement(true)
	Utils.get_current_player().set_movment_animation(true)
	Utils.get_current_player().set_player_can_interact(true)


func _on_Settings_pressed():
	Utils.get_main().add_settings()

# Close game and go to main menu
func _on_Back_to_Main_Menu_pressed():
	var transition_data = TransitionData.Menu.new(Constants.MAIN_MENU_PATH)
	Utils.get_game_menu().queue_free()
	Utils.get_ui().in_world(false)
	Utils.get_scene_manager().transition_to_scene(transition_data)
	var data = Utils.get_current_player().get_data()
	data.cooldown = Utils.get_hotbar().get_node("Hotbar/Timer").time_left
	Utils.get_hotbar().get_node("Hotbar/Timer").stop()
	Utils.get_hotbar()._on_Timer_timeout()
	Utils.get_current_player().save_player_data(data)
	
	# Stop game
	Utils.stop_game()

func _on_Exit_Game_pressed():
	# Stop game
	Utils.stop_game()
	
	# Quit and close game
	get_tree().quit()
