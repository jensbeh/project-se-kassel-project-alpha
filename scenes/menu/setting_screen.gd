extends CanvasLayer


# Variables
var CUSTOM_WINDOW_SIZE_ID = Constants.get_valid_window_sizes().size()
var window_fullscreen = {
	0: {
		"text": tr("WINDOW_FULLSCREEN_OFF"),
		"value": false
	},
	1: {
		"text": tr("WINDOW_FULLSCREEN_ON"),
		"value": true
	}
}

# Nodes
onready var settingsLabel = find_node("SettingsLabel")
onready var backButton = $Back
onready var volumeLabel = find_node("VolumeLabel")
onready var musicLabel = find_node("MusicLabel")
onready var musicSlider = find_node("MusicSlider")
onready var soundsLabel = find_node("SoundsLabel")
onready var soundSlider = find_node("SoundSlider")
onready var languageLabel = find_node("LanguageLabel")
onready var languageOptionButton = find_node("LanguageOptionButton")
onready var windowLabel = find_node("WindowLabel")
onready var windowSizeLabel = find_node("SizeLabel")
onready var windowSizeOptionButton = find_node("SizeOptionButton")
onready var windowFullscreenLabel = find_node("FullscreenLabel")
onready var windowFullscreenOptionButton = find_node("FullscreenOptionButton")

func _ready():
	settingsLabel.set_text(tr("SETTINGS"))
	backButton.set_text(tr("BACK"))
	volumeLabel.set_text(tr("VOLUME"))
	musicLabel.set_text(tr("MUSIC"))
	soundsLabel.set_text(tr("SOUNDS"))
	languageLabel.set_text(tr("LANGUAGE"))
	windowLabel.set_text(tr("WINDOW"))
	windowSizeLabel.set_text(tr("WINDOW_SIZE"))
	windowFullscreenLabel.set_text(tr("WINDOW_FULLSCREEN"))
	
	# Setup sounds/music slider
	soundSlider.value = Utils.get_sound_volume()
	musicSlider.value = Utils.get_music_volume()
	
	# Setup language options
	# Add items
	if languageOptionButton.get_item_count() < 2:
		languageOptionButton.add_item("English")
		languageOptionButton.add_item("Deutsch")
	# Select item
	var language = Utils.get_language()
	if language == "en":
		languageOptionButton.select(0)
	else:
		languageOptionButton.select(1)
	
	# Setup window_size options
	windowSizeOptionButton.clear()
	var window_size_selected = false
	for window_size_dic in Constants.get_valid_window_sizes():
		# Add all window sizes
		windowSizeOptionButton.add_item(window_size_dic.text, Constants.get_valid_window_sizes().find(window_size_dic))
		# Select current window size
		if window_size_dic.value == Utils.get_window_size():
			windowSizeOptionButton.select(Constants.get_valid_window_sizes().find(window_size_dic))
			window_size_selected = true
	# Select "Custom" if window size is diffrent to these in list
	if not window_size_selected:
		windowSizeOptionButton.add_item(tr("CUSTOM_WINDOW_SIZE"), CUSTOM_WINDOW_SIZE_ID)
		windowSizeOptionButton.select(CUSTOM_WINDOW_SIZE_ID)
	
	# Setup window_fullscreen options
	window_fullscreen[0].text = tr("WINDOW_FULLSCREEN_OFF")
	window_fullscreen[1].text = tr("WINDOW_FULLSCREEN_ON")
	windowFullscreenOptionButton.clear()
	# Add items
	if windowFullscreenOptionButton.get_item_count() < 2:
		windowFullscreenOptionButton.add_item(window_fullscreen[0].text)
		windowFullscreenOptionButton.add_item(window_fullscreen[1].text)
	# Select item
	if Utils.get_window_fullscreen() == true:
		windowSizeOptionButton.set_deferred("disabled", true)
		windowFullscreenOptionButton.select(1)
	else:
		windowSizeOptionButton.set_deferred("disabled", false)
		windowFullscreenOptionButton.select(0)


# Method to set all settings and save them to file
func save_settings():
	Constants.GAME_SETTINGS.language = Utils.get_language()
	Constants.GAME_SETTINGS.sound = soundSlider.value
	Constants.GAME_SETTINGS.music = musicSlider.value
	Constants.GAME_SETTINGS.window_size = var2str(Utils.get_window_size())
	Constants.GAME_SETTINGS.window_maximized = Utils.get_window_maximized()
	Constants.GAME_SETTINGS.window_fullscreen = Utils.get_window_fullscreen()
	FileManager.save_settings()


# Method called form slider if selecting new position
func _on_Musicslieder_value_changed(value):
	AudioServer.set_bus_volume_db(1, value)
	Utils.set_music_volume(value)
	if value == -40:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
	save_settings()


# Method called form slider if selecting new position
func _on_Soundslider_value_changed(value):
	AudioServer.set_bus_volume_db(2, value)
	Utils.set_sound_volume(value)
	if value == -40:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
	save_settings()


# Method called form option button if selecting new item
func _on_Language_selected(index):
	Utils.set_and_play_sound(Constants.PreloadedSounds.Switch)
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


# Method called form option button if selecting new item
func _on_Window_Size_selected(index):
	# Set to window
	if Utils.get_window_maximized():
		Utils.set_window_maximized(false, true)
	Utils.set_window_size(Constants.get_valid_window_sizes()[index].value, true)
	
	# Save
	save_settings()
	_ready()


# Method called form option button if selecting new item
func _on_Window_Fullscreen_selected(index):
	# Set to window
	Utils.set_window_fullscreen(window_fullscreen[index].value, true)
	
	# Save
	save_settings()
	
	# Update window size option button depending on fullscreen or not 
	if OS.is_window_fullscreen():
		windowSizeOptionButton.set_deferred("disabled", true)
	else:
		windowSizeOptionButton.set_deferred("disabled", false)


# Close settings and resetup the scene
func _on_Back_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	queue_free()
	Utils.get_control_notes()._ready()
	if (Utils.get_game_menu() != null):
		Utils.get_game_menu()._ready()
		Utils.setting_screen(false)
	if (Utils.get_scene_manager().get_child(0).get_node_or_null("MainMenuScreen")) != null:
		# Called Settings from MainMenuScreen
		# Need to enable gui in viewport of game again
		Utils.get_main().disable_game_gui(false)
		Utils.get_scene_manager().get_child(0).get_node("MainMenuScreen")._ready()


# Method to refresh the ui
func update_ui():
	_ready()
