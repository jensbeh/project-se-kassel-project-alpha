extends CanvasLayer


func _ready():
	get_node("Exit Game").set_text(tr("EXIT_GAME"))
	get_node("Back to Main Menu").set_text(tr("BACK_TO_MAIN_MENU"))
	get_node("Back to Game").set_text(tr("BACK_TO_GAME"))
	get_node("Settings").set_text(tr("SETTINGS"))


# Close game menu and set playermovemnt true
func _on_Back_to_Game_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	Utils.remove_game_menu()
	Utils.get_current_player().set_movement(true)
	Utils.get_current_player().set_movment_animation(true)
	Utils.get_current_player().set_player_can_interact(true)


func _on_Settings_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	
	Utils.setting_screen(true)
	Utils.add_settings_screen()


# Close game and go to main menu
func _on_Back_to_Main_Menu_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	
	var transition_data = TransitionData.Menu.new(Constants.MAIN_MENU_PATH)
	
	# Remove game menu
	Utils.remove_game_menu()
	# Make ui invisible
	Utils.get_ui().in_world(false)
	
	# Save cooldown to player
	Utils.get_hotbar().save_and_stop_timer()
	
	Utils.get_scene_manager().transition_to_scene(transition_data)


func _on_Exit_Game_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	
	# Remove game menu
	Utils.remove_game_menu()
	
	# Save cooldown to player
	Utils.get_hotbar().save_and_stop_timer()
	
	# Stop game
	Utils.stop_game()
