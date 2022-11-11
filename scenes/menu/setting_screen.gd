extends CanvasLayer


func _ready():
	get_node("Settings").set_text(tr("SETTINGS"))
	get_node("Back").set_text(tr("BACK"))
	get_node("Volume").set_text(tr("VOLUME"))
	get_node("Music").set_text(tr("MUSIC"))
	get_node("Sounds").set_text(tr("SOUNDS"))
	get_node("Language").set_text(tr("LANGUAGE"))
	$Soundslider.value = Utils.get_sound_volume()
	$Musicslieder.value = Utils.get_music_volume()
	if get_node("OptionButton").get_item_count() < 2:
		get_node("OptionButton").add_item("English")
		get_node("OptionButton").add_item("Deutsch")
	var language = Utils.get_language()
	if language == "en":
		get_node("OptionButton").select(0)
	else:
		get_node("OptionButton").select(1)
	set_layer(2)


var save_setting = {
		language = Utils.get_language(),
		sound = 0,
		music = 0
	}


func save_settings():
	save_setting.language = Utils.get_language()
	save_setting.sound = $Soundslider.value
	save_setting.music = $Musicslieder.value
	var save_game = File.new()
	save_game.open(Constants.SAVE_SETTINGS_PATH, File.WRITE)
	save_game.store_line(to_json(save_setting))
	save_game.close()


func _on_Musicslieder_value_changed(value):
	AudioServer.set_bus_volume_db(1, value)
	Utils.set_music_volume(value)
	if value == -30:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
	save_settings()


func _on_Soundslider_value_changed(value):
	AudioServer.set_bus_volume_db(2, value)
	Utils.set_sound_volume(value)
	if value == -30:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
	save_settings()


func _on_OptionButton_item_selected(index):
	Utils.get_sound_player().stream = Constants.PreloadedSounds.Switch
	Utils.get_sound_player().play(0.03)
	if index == 0:
		TranslationServer.set_locale('en')
		Utils.set_language("en")
	else:
		TranslationServer.set_locale('de')
		Utils.set_language("de")
	TranslationServer.set_locale(Utils.get_language())
	_ready()
	save_settings()
	Utils.update_language()


# Close settings and resetup the scene
func _on_Back_pressed():
	Utils.get_sound_player().stream = Constants.PreloadedSounds.Click
	Utils.get_sound_player().play(0.03)
	Utils.get_main().get_node("SettingScreen").queue_free()
	Utils.get_control_notes()._ready()
	if (Utils.get_game_menu() != null):
		Utils.get_game_menu()._ready()
		Utils.setting_screen(false)
	if (Utils.get_scene_manager().get_child(0).get_node_or_null("MainMenuScreen")) != null:
		# Called Settings from MainMenuScreen
		# Need to enable gui in viewport of game again
		Utils.get_main().disable_game_gui(false)
		Utils.get_scene_manager().get_child(0).get_node("MainMenuScreen")._ready()
	
