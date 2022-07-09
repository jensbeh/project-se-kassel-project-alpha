extends CanvasLayer

const SAVE_PATH = "user://"
const SAVE_FILE_EXTENSION = ".json"

func _ready():
	get_node("Settings").set_text(tr("SETTINGS"))
	get_node("Back").set_text(tr("BACK"))
	get_node("Volume").set_text(tr("VOLUME"))
	get_node("Music").set_text(tr("MUSIC"))
	get_node("Sounds").set_text(tr("SOUNDS"))
	get_node("Language").set_text(tr("LANGUAGE"))
	if get_node("OptionButton").get_item_count() < 2:
		get_node("OptionButton").add_item("English")
		get_node("OptionButton").add_item("Deutsch")
	var language = Utils.get_language()
	if language == "en":
		get_node("OptionButton").select(0)
	else:
		get_node("OptionButton").select(1)


var save_setting = {
		language = Utils.get_language()
	}


func save_settings():
	save_setting.language = Utils.get_language()
	var save_game = File.new()
	save_game.open(SAVE_PATH + "settings" + SAVE_FILE_EXTENSION, File.WRITE)
	save_game.store_line(to_json(save_setting))
	save_game.close()


func _on_Musicslieder_value_changed(_value):
	pass # Replace with function body.


func _on_Soundslider_value_changed(_value):
	pass # Replace with function body.


func _on_OptionButton_item_selected(index):
	if index == 0:
		TranslationServer.set_locale('en')
		Utils.set_language("en")
	else:
		TranslationServer.set_locale('de')
		Utils.set_language("de")
	TranslationServer.set_locale(Utils.get_language())
	_ready()
	save_settings()

# close settings and resetup the scene
func _on_Back_pressed():
	Utils.get_scene_manager().get_node("SettingScreen").queue_free()
	if (Utils.get_scene_manager().get_child(3).get_node_or_null("GameMenu") != null):
		Utils.get_scene_manager().get_child(3).get_node("GameMenu")._ready()
	if (Utils.get_scene_manager().get_child(0).get_node_or_null("MainMenuScreen")) != null:
		Utils.get_scene_manager().get_child(0).get_node("MainMenuScreen")._ready()
	
