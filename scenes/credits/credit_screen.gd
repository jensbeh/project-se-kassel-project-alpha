extends Node2D

onready var line = get_node("CreditsContainer/Line")

const section_time = 2.5
const line_time = 2
const title_color = Color(0.3,0.14,0,1)

var title_font = DynamicFont.new()

var phraseNum = 0
var section
var section_next = false
var finished = false

var line_timer = 0
var section_timer = -2

var lines = []

var credits
var credits_en = [
	[
		"Project Alpha"
	],[
		"Tilesets and sprites"
	],[
		"Overworld and buildings",
		"jamiebrownhill.itch.io - solaria-quiet-cabin",
		"jamiebrownhill.itch.io - solaria-rural-village",
		"secrethideout.itch.io - rogue-dungeon-tileset-16x16",
	],[
		"Mobs",
		"henrysoftware.itch.io - pixel-mob",
		"jamiebrownhill.itch.io - solaria-enemy-pack",
	],[
		"Items",
		"@JoeCreates OpenGameArt.org Joe Williamson - roguelikeitems",
		"\"Matt Firth (cheekyinkling)\" and \"game-icons.net\" cheekyinkling.itch.io \n - shikashis-fantasy-icons-pack",
	],[
		"Character",
		"https://shubibubi.itch.io/ - cozy people",
	],[
		"UI",
		"karwisch.itch.io - pxui-basic",
	],[
		"Music",
	],[
		"Houses",
		"OpenGameArt.org Yubatake - menuloops",
		"http://soundcloud.com/rezoner - Rezoner-Pirates_Theme",
		"OpenGameArt.org syncopika - forest",
		"OpenGameArt.org OwlishMedia - Owlish Media Sound Effects",
	],[
		"Menu",
		"OpenGameArt.org mrpoly - awesomeness",
	],[
		"Battle",
		"http://pixelsphere.org http://cynicmusic.com - battleThemeB",
		"cynicmusic.com pixelsphere.org - battleThemeA",
	],[
		"Overworld",
		"OpenGameArt.org bart - little town -orchestral",
		"OpenGameArt.org vi1e8 - Outdoor_Ambiance",
		"OpenGameArt.org OwlishMedia - Owlish Media Sound Effects",
		"Additional samples by Ove Melaa (Omsofware@hotmail.com) -2013 Ove Melaa \n - EssentialGameAudiopack",
	],[
		"Credits",
		"Music by Cleyton Kauffman - https://soundcloud.com/cleytonkauffman \n - End_Credits_Theme",
	],[
		"Sound effects",
	],[
		"Battle and UI",
		"www.kenney.nl OpenGameArt.org Kenney - UI_SFX_Set",
		"OpenGameArt.org artistcdude - rpg_sound_pack",
		"OpenGameArt.org Timopy - SFX",
		"OpenGameArt.org Indepentent.nu - independent_nu_ljudbank-hits_and_punches",
		"OpenGameArt.org Little Robot Sound Factory www.littlerobotsoundfactory.com \n - Fantasy Sound Library",
		"\"Level up sound effects\" by Bart Kelsey. Commissioned by Will Corwin \n for OpenGameArt.org (http://opengameart.org)",
	],[
		"Treasures and doors",
		"Sound package from Heroes of Hawks Haven By Tuomo Untinen - soundpack",
		"www.kenney.nl OpenGameArt.org Kenney - RPGsounds_Kenney",
	],[
		"Player",
		"OpenGameArt.org Jute - jute-dh-steps",
		"OpenGameArt.org OwlishMedia - Owlish Media Sound Effects",
	],[
		"Dialogue",
		"alan-dalcastagne.itch.io - DialogTextSoundEffects",
	],[
		"Tools"
	],[
		"Developed with Godot Engine",
		"https://godotengine.org/license",
	],[
		"Maps created with Tiled",
		"https://www.mapeditor.org",
	],[
		"Addons",
		"https://github.com/binogure-studio/godot-uuid",
		"https://github.com/vnen/godot-tiled-importer"
	],[
		"Lighting system",
		"https://www.patreon.com/posts/42040761"
	],[
		"Programming",
		"Jens Behmenburg",
		"&",
		"Tim Kolitsch"
	]
]
var credits_de = [
	[
		"Project Alpha"
	],[
		"Tilesets und Sprites"
	],[
		"Welt und Gebäude",
		"jamiebrownhill.itch.io - solaria-quiet-cabin",
		"jamiebrownhill.itch.io - solaria-rural-village",
		"secrethideout.itch.io - rogue-dungeon-tileset-16x16",
	],[
		"Mobs",
		"henrysoftware.itch.io - pixel-mob",
		"jamiebrownhill.itch.io - solaria-enemy-pack",
	],[
		"Gegenstände",
		"@JoeCreates OpenGameArt.org Joe Williamson - roguelikeitems",
		"\"Matt Firth (cheekyinkling)\" and \"game-icons.net\" cheekyinkling.itch.io \n - shikashis-fantasy-icons-pack",
	],[
		"Charakter",
		"https://shubibubi.itch.io/ - cozy people",
	],[
		"UI",
		"karwisch.itch.io - pxui-basic",
	],[
		"Musik",
	],[
		"Häuser",
		"OpenGameArt.org Yubatake - menuloops",
		"http://soundcloud.com/rezoner - Rezoner-Pirates_Theme",
		"OpenGameArt.org syncopika - forest",
		"OpenGameArt.org OwlishMedia - Owlish Media Sound Effects",
	],[
		"Menü",
		"OpenGameArt.org mrpoly - awesomeness",
	],[
		"Kampf",
		"http://pixelsphere.org http://cynicmusic.com - battleThemeB",
		"cynicmusic.com pixelsphere.org - battleThemeA",
	],[
		"Welt",
		"OpenGameArt.org bart - little town -orchestral",
		"OpenGameArt.org vi1e8 - Outdoor_Ambiance",
		"OpenGameArt.org OwlishMedia - Owlish Media Sound Effects",
		"Additional samples by Ove Melaa (Omsofware@hotmail.com) -2013 Ove Melaa \n - EssentialGameAudiopack",
	],[
		"Credits",
		"Music by Cleyton Kauffman - https://soundcloud.com/cleytonkauffman \n - End_Credits_Theme",
	],[
		"Soundeffekte",
	],[
		"Kampf und UI",
		"www.kenney.nl OpenGameArt.org Kenney - UI_SFX_Set",
		"OpenGameArt.org artistcdude - rpg_sound_pack",
		"OpenGameArt.org Timopy - SFX",
		"OpenGameArt.org Indepentent.nu - independent_nu_ljudbank-hits_and_punches",
		"OpenGameArt.org Little Robot Sound Factory www.littlerobotsoundfactory.com \n - Fantasy Sound Library",
		"\"Level up sound effects\" by Bart Kelsey. Commissioned by Will Corwin \n for OpenGameArt.org (http://opengameart.org)",
	],[
		"Schatztruhen und Türen",
		"Sound package from Heroes of Hawks Haven By Tuomo Untinen - soundpack",
		"www.kenney.nl OpenGameArt.org Kenney - RPGsounds_Kenney",
	],[
		"Spieler",
		"OpenGameArt.org Jute - jute-dh-steps",
		"OpenGameArt.org OwlishMedia - Owlish Media Sound Effects",
	],[
		"Dialog",
		"alan-dalcastagne.itch.io - DialogTextSoundEffects",
	],[
		"Werkzeuge"
	],[
		"Entwickelt mit Godot Engine",
		"https://godotengine.org/license",
	],[
		"Maps erstellt mit Tiled",
		"https://www.mapeditor.org",
	],[
		"Addons",
		"https://github.com/binogure-studio/godot-uuid",
		"https://github.com/vnen/godot-tiled-importer"
	],[
		"Lichtsystem",
		"https://www.patreon.com/posts/42040761"
	],[
		"Programmierung",
		"Jens Behmenburg",
		"&",
		"Tim Kolitsch"
	]
]

# Called when the node enters the scene tree for the first time.
func _ready():
	title_font.font_data = load("res://assets/Hack_Regular.ttf")
	title_font.set_size(56)
	
	get_node("Back").set_text(tr("BACK"))
	
	Utils.set_and_play_music(Constants.PreloadedMusic.Credits)
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()
	
	if Utils.get_language() == "en":
		credits = credits_en
	else:
		credits = credits_de
	
	# start credits
	section = credits.pop_front()
	add_line()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if section_next:
		section_timer += delta * 1.5
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				section = credits.pop_front()
				phraseNum = 0
				add_line()
	else:
		line_timer += delta * 1.5
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if lines.size() > 0:
		for l in lines:
			l.rect_position.y -= 100 * delta
			if l.rect_position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif !finished:
		finish()


# End Credit Screen
func finish():
	if not finished:
		finished = true
		var transition_data = TransitionData.Menu.new(Constants.MAIN_MENU_PATH)
		Utils.get_scene_manager().transition_to_scene(transition_data)
	

# Method to end Credit Screen
func _input(event):
	if event.is_action_pressed("esc"):
		finish()
	
	
func add_line():
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if phraseNum == 0:
		new_line.add_color_override("font_color", title_color)
		if new_line.text in ["Music", "Tilesets and sprites", "Project Alpha", "Sound effects", "Tools", "Tilesets und Sprites", "Musik", "Soundeffekte", "Werkzeuge"]:
			new_line.add_font_override("font", title_font)
		if new_line.text == "Programming":
			new_line.add_font_override("font", title_font)
	get_node("CreditsContainer").add_child(new_line)
	
	if section.size() > 0:
		phraseNum += 1
		section_next = false
		if new_line.text in ["Jens Behmenburg", "&",]:
			line_timer += 1
	else:
		if credits != null:
			if credits.front() != null:
				if credits.front().front() in  ["Music", "Tilesets and sprites", "Project Alpha", "Sound effects", "Tools", "Tilesets und Sprites", "Musik", "Soundeffekte", "Werkzeuge"]:
					section_timer -= 2
		section_next = true


func destroy_scene():
	pass


func _on_Back_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	finish()
