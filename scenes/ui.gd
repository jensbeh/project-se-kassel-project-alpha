extends CanvasLayer

# Variables
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
			Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI)
			
			Utils.get_current_player().set_movement(false)
			Utils.get_current_player().set_movment_animation(false)
			Utils.get_current_player().set_player_can_interact(false)
			Utils.get_ui().add_child(Constants.PreloadedScenes.GameMenuScene.instance())
		# Close game menu with "esc" when game menu is open
		elif event.is_action_pressed("esc") and !Utils.get_current_player().get_movement() and Utils.get_game_menu() != null and not Utils.in_setting_screen:
			# Sound
			
			Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI)
			
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			Utils.get_current_player().set_player_can_interact(true)
			Utils.remove_game_menu()
		
		# Open character inventory with "i"
		elif (event.is_action_pressed("character_inventory") and Utils.get_current_player().get_movement() and 
		not Utils.get_current_player().collecting and 
		not Utils.get_current_player().is_player_dying() and Utils.get_character_interface() == null):
			# Sound
			Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI2)
			
			Utils.get_current_player().set_movement(false)
			Utils.get_current_player().set_movment_animation(false)
			Utils.get_current_player().set_player_can_interact(false)
			Utils.get_ui().add_child(Constants.PreloadedScenes.CharacterInterfaceScene.instance())
		# Close character inventory with "i"
		elif (event.is_action_pressed("character_inventory") and not Utils.get_current_player().get_movement() 
		and Utils.get_character_interface() != null):
			# Sound
			Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI)
			
			Utils.get_current_player().set_movement(true)
			Utils.get_current_player().set_movment_animation(true)
			Utils.get_current_player().set_player_can_interact(true)
			PlayerData.inv_data["Weapon"] = PlayerData.equipment_data["Weapon"]
			PlayerData.inv_data["Light"] = PlayerData.equipment_data["Light"]
			PlayerData.inv_data["Hotbar"] = PlayerData.equipment_data["Hotbar"]
			Utils.save_game(true)
			Utils.get_character_interface().exit_scene()
		
		# Use Item from Hotbar
		elif event.is_action_pressed("hotbar") and not Utils.get_current_player().is_player_dying():
			Utils.get_hotbar().use_item()
			
		# Control Notes
		elif event.is_action_pressed("control_notes") and not is_dialog:
			# Sound
			Utils.set_and_play_sound(Constants.PreloadedSounds.open_close)
			
			Utils.get_control_notes().show_hide_control_notes()
			
		# open map
		elif ((Utils.get_scene_manager().get_current_scene_type() == Constants.SceneType.CAMP or 
		Utils.get_scene_manager().get_current_scene_type() == Constants.SceneType.GRASSLAND) and not is_dialog):
			if event.is_action_pressed("map") and has_map and !show_map:
				# Sound
				Utils.set_and_play_sound(Constants.PreloadedSounds.open_close)
				
				show_map = true
				Utils.get_current_player().get_data().show_map = show_map
				Utils.get_minimap().update_minimap()
		
			# close map
			elif event.is_action_pressed("map") and has_map and show_map:
				# Sound
				Utils.set_and_play_sound(Constants.PreloadedSounds.open_close)
				
				show_map = false
				Utils.get_current_player().get_data().show_map = show_map
				Utils.get_minimap().update_minimap()
	
	# Close Quest List
	if event.is_action_pressed("esc") and get_node_or_null("QuestList") != null:
		get_node_or_null("QuestList").queue_free()
		Utils.get_current_player().set_player_can_interact(true)
		Utils.get_current_player().set_movement(true)
		Utils.get_current_player().set_movment_animation(true)
		Utils.get_current_player().pause_player(false)
		for npc in Utils.get_scene_manager().get_child(0).get_child(0).find_node("npclayer").get_children():
			npc.set_interacted(false)
