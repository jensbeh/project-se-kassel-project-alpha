extends CanvasLayer

var input
var show_map = false
var has_map = false
var is_dialog = false


func _ready():
	pass


func in_world(value):
	if value:
		get_node("ControlNotes").in_world(value)
		get_node("PlayerUI").visible = value
	else:
		get_node("ControlNotes").in_world(value)
		get_node("PlayerUI").visible = value


# pause and resume the player input
func player_input(new_value):
	input = new_value


func _input(event):
	Utils.get_control_notes().update()
	# only can do interactions while mot scene changeing
	if input:
		# Open game menu with "esc"
		if (event.is_action_pressed("esc") and Utils.get_current_player().get_movement() and 
		not Utils.get_current_player().hurting and not Utils.get_current_player().is_player_dying() and 
		Utils.get_game_menu() == null):
			# Sound
			Utils.get_sound_player().stream = Constants.PreloadedSounds.OpenUI
			Utils.get_sound_player().play(0.03)
			
			Utils.get_current_player().set_movement(false)
			Utils.get_current_player().set_movment_animation(false)
			Utils.get_current_player().set_player_can_interact(false)
			Utils.get_ui().add_child(load(Constants.GAME_MENU_PATH).instance())
		# Close game menu with "esc" when game menu is open
		elif event.is_action_pressed("esc") and !Utils.get_current_player().get_movement() and Utils.get_game_menu() != null and not Utils.in_setting_screen:
			# Sound
			
			Utils.get_sound_player().stream = Constants.PreloadedSounds.OpenUI
			Utils.get_sound_player().play(0.03)
			
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			Utils.get_current_player().set_player_can_interact(true)
			Utils.get_game_menu().queue_free()
		
		# Open character inventory with "i"
		elif (event.is_action_pressed("character_inventory") and Utils.get_current_player().get_movement() and 
		not Utils.get_current_player().collecting and 
		not Utils.get_current_player().is_player_dying() and Utils.get_character_interface() == null):
			# Sound
			Utils.get_sound_player().stream = Constants.PreloadedSounds.OpenUI2
			Utils.get_sound_player().play(0.03)
			
			Utils.get_current_player().set_movement(false)
			Utils.get_current_player().set_movment_animation(false)
			Utils.get_current_player().set_player_can_interact(false)
			Utils.get_ui().add_child(load(Constants.CHARACTER_INTERFACE_PATH).instance())
		# Close character inventory with "i"
		elif (event.is_action_pressed("character_inventory") and not Utils.get_current_player().get_movement() 
		and Utils.get_character_interface() != null):
			# Sound
			Utils.get_sound_player().stream = Constants.PreloadedSounds.OpenUI
			Utils.get_sound_player().play(0.03)
			
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			Utils.get_current_player().set_player_can_interact(true)
			PlayerData.inv_data["Weapon"] = PlayerData.equipment_data["Weapon"]
			PlayerData.inv_data["Light"] = PlayerData.equipment_data["Light"]
			PlayerData.inv_data["Hotbar"] = PlayerData.equipment_data["Hotbar"]
			Utils.save_game(true)
			Utils.get_character_interface().queue_free()
		
		# Use Item from Hotbar
		elif event.is_action_pressed("hotbar") and not Utils.get_current_player().is_player_dying():
			Utils.get_hotbar().use_item()
			
		# Control Notes
		elif event.is_action_pressed("control_notes") and not is_dialog:
			# Sound
			Utils.get_sound_player().stream = Constants.PreloadedSounds.open_close
			Utils.get_sound_player().play(0.03)
			
			Utils.get_control_notes().show_hide_control_notes()
			
		# open map
		elif (Utils.get_scene_manager().get_current_scene_type() != Constants.SceneType.DUNGEON and not is_dialog):
			if event.is_action_pressed("map") and has_map and !show_map:
				# Sound
				Utils.get_sound_player().stream = Constants.PreloadedSounds.open_close
				Utils.get_sound_player().play(0.03)
				
				show_map = true
				Utils.get_current_player().get_data().show_map = show_map
				Utils.get_minimap().update_minimap()
		
			# close map
			elif event.is_action_pressed("map") and has_map and show_map:
				# Sound
				Utils.get_sound_player().stream = Constants.PreloadedSounds.open_close
				Utils.get_sound_player().play(0.03)
				
				show_map = false
				Utils.get_current_player().get_data().show_map = show_map
				Utils.get_minimap().update_minimap()

