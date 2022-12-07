extends Node2D

const uuid_util = preload("res://addons/uuid.gd")

onready var scenePlayer = Utils.get_player()
onready var characterSettingsContainer = $ScrollContainer
onready var line_editRegEx = RegEx.new()

var characters_existing = false
var uuid
var charac_name = ""
# Count Textures, Count Colors
var curr_body: int = 0
var curr_shoes: int = 0
var curr_shoe_color: int = 1
var curr_pants: int = 1
var curr_pants_color: int = 1
var curr_clothes: int = 8
var curr_clothes_color: int = 0
var curr_blush: int = 0
var curr_blush_color: int = 0
var curr_lipstick: int = 0
var curr_lipstick_color: int = 0
var curr_beard: int = 0
var curr_beard_color: int = 0
var curr_eyes: int = 0
var curr_eyes_color: int = 0
var curr_earring: int = 0
var curr_hair: int = 8
var curr_hair_color: int = 0
var curr_mask: int = 0
var curr_glasses: int = 0
var curr_hat: int = 0

# Sprites
var body
var shoes
var pants
var clothes
var blush
var lipstick
var beard
var eyes
var hair
var shadow

# Nodes
onready var HairCountNode = find_node("HairCount");
onready var HairColorCountNode = find_node("HairColorCount");
onready var SkinCountNode = find_node("SkinCount");
onready var TorsoCountNode = find_node("TorsoCount");
onready var TorsoColorCountNode = find_node("TorsoColorCount");
onready var LegsCountNode = find_node("LegsCount");
onready var LegsColorCountNode = find_node("LegsColorCount");
onready var ShoesCountNode = find_node("ShoesCount");
onready var EyesCountNode = find_node("EyesCount");
onready var BeardCountNode = find_node("BeardCount");
onready var MakeupCountNode = find_node("MakeupCount");
onready var HairColorLeftNode = find_node("HairColorLeft");
onready var HairColorRightNode = find_node("HairColorRight");
onready var LineEditNode = find_node("LineEdit");

func _ready():
	# Check if charcter are available to go back to main menu if there is no character which can be loaded
	var character_list = Utils.get_all_character_data()
	if not character_list.empty():
		characters_existing = true
	
	find_node("Name").set_text(tr("CHARACTER_NAME"))
	find_node("Skincolor").set_text(tr("SKINCOLOR"))
	find_node("Hair").set_text(tr("HAIR"))
	find_node("Haircolor").set_text(tr("HAIR_COLOR"))
	find_node("Shoes").set_text(tr("SHOES"))
	find_node("Eyes").set_text(tr("EYES"))
	find_node("Torso").set_text(tr("TORSO"))
	find_node("Torsocolor").set_text(tr("TORSO_COLOR"))
	find_node("Legs").set_text(tr("LEGS"))
	find_node("Legcolor").set_text(tr("LEGS_COLOR"))
	find_node("Beard").set_text(tr("BEARD"))
	find_node("Make-Up").set_text(tr("MAKE_UP"))
	find_node("Create Character").set_text(tr("CREATE_CHARACTER"))
	find_node("Back").set_text(tr("BACK_TO_CHARACTER_CHOICE"))
	find_node("LineEdit").set_placeholder("ENTER_NAME_HERE")
	
	if characters_existing:
		find_node("Back").set_text(tr("BACK_TO_CHARACTER_CHOICE"))
	else:
		find_node("Back").set_text(tr("BACK_TO_MAIN_MENU"))
	
	get_sprites()
	
	scenePlayer.set_movement(false)
	
	beard.visible = false
	blush.visible = false
	lipstick.visible = false
	shadow.visible = true
	
	uuid = uuid_util.v4()
	
	# Set preset to character
	# UI
	HairCountNode.set_text(str(curr_hair))
	HairColorCountNode.set_text(str(curr_hair_color))
	SkinCountNode.set_text(str(curr_body))
	TorsoCountNode.set_text(str(curr_clothes))
	TorsoColorCountNode.set_text(str(curr_clothes_color))
	LegsCountNode.set_text(str(curr_pants))
	LegsColorCountNode.set_text(str(curr_pants_color))
	ShoesCountNode.set_text(str(curr_shoe_color))
	EyesCountNode.set_text(str(curr_eyes))
	BeardCountNode.set_text(str(curr_beard))
	MakeupCountNode.set_text(str(curr_blush))
	# PLAYER (Color & Sprite)
	# Body
	scenePlayer.set_texture("curr_body", curr_body)
	# Shoes
	scenePlayer.reset_key(1)
	scenePlayer._set_key(1, curr_shoe_color*8)
	scenePlayer.set_texture("curr_shoes", curr_shoes)
	# Pants
	scenePlayer.reset_key(2)
	scenePlayer._set_key(2, curr_pants_color*8)
	scenePlayer.set_texture("curr_pants", curr_pants)
	# Clothes
	scenePlayer.reset_key(3)
	scenePlayer._set_key(3, curr_clothes_color*8)
	scenePlayer.set_texture("curr_clothes", curr_clothes)
	# Hairs
	scenePlayer.reset_key(9)
	scenePlayer._set_key(9, curr_hair_color*8)
	scenePlayer.set_texture("curr_hair", curr_hair-1)
	# Eyes
	scenePlayer.reset_key(7)
	scenePlayer._set_key(7, curr_eyes_color*8)
	scenePlayer.set_texture("curr_eyes", curr_eyes)
	# Beard
	if curr_beard_color > 0:
		scenePlayer.reset_key(6)
		scenePlayer._set_key(6, (curr_beard_color-1)*8)
	scenePlayer.set_texture("curr_beard", curr_beard)
	# Blush
	if curr_lipstick_color > 0:
		scenePlayer.reset_key(5)
		scenePlayer._set_key(5, (curr_lipstick_color-1)*8)
	scenePlayer.set_texture("curr_blush", curr_blush)
	# Set frames
	reset_frame()
	
	HairColorLeftNode.disabled = false
	HairColorRightNode.disabled = false
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()
	
	line_editRegEx.compile("^([\\w\\-öüäÄÜÖ]+((\\x20?)[\\w\\-öüäÄÜÖ]+)+|[\\w\\-öüäÄÜÖ]+)+$")


# Method to destroy the scene
# Is called when SceneManager changes scene after loading new scene
func destroy_scene():
	pass


func get_sprites():
	for child in scenePlayer.get_children():
		match child.name:
			"Body":
				body = child
			"Shoes":
				shoes = child
			"Pants":
				pants = child
			"Clothes":
				clothes = child
			"Blush":
				blush = child
			"Lipstick":
				lipstick = child
			"Beard":
				beard = child
			"Eyes":
				eyes = child
			"Hair":
				hair = child
			"Shadow":
				shadow = child


var save_game_data = {
	"name": charac_name,
	"level": 1,
	"exp": 0,
	"maxStamina": 100.0,
	"stamina": 100.0,
	"maxLP": 100,
	"attack": 15,
	"attack_speed": 4,
	"knockback": 0,
	"currentHP": 100,
	"gold": 100,
	"light": 0,
	"cooldown": 0,
	"stamina_cooldown": 0,
	"has_map": false,
	"show_map": false,
	"skincolor": curr_body,
	"hairs": curr_hair,
	"hair_color": curr_hair_color,
	"torso": curr_clothes,
	"torso_color": curr_clothes_color,
	"legs": curr_pants,
	"legs_color": curr_pants_color,
	"eyes": curr_eyes,
	"eyes_color": curr_eyes_color,
	"shoes": curr_shoes,
	"shoe_color": curr_shoe_color,
	"lipstick": curr_lipstick,
	"lipstick_color": curr_lipstick_color,
	"blush": curr_blush,
	"blush_color": curr_blush_color,
	"beard": curr_beard,
	"beard_color": curr_beard_color,
	"hat": curr_hat,
	"mask": curr_mask,
	"earring": curr_earring,
	"glasses": curr_glasses,
	"id" : uuid,
	"view_direction": var2str(Vector2(0,1)),
	"passed_days": 0,
	"quest": "",
	"quest_finished": false,
	"quest_progress": 0,
}


func _on_Back_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	
	if characters_existing:
		var transition_data = TransitionData.Menu.new(Constants.CHARACTER_SCREEN_PATH)
		Utils.get_scene_manager().transition_to_scene(transition_data)
	else:
		var transition_data = TransitionData.Menu.new(Constants.MAIN_MENU_PATH)
		Utils.get_scene_manager().transition_to_scene(transition_data)


func _on_Create_Character_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Select)
	
	if charac_name.ends_with(" "):
		LineEditNode.delete_char_at_cursor()
	
	if charac_name != "":
		save_game_data.skincolor = curr_body
		save_game_data.shoes = curr_shoes
		save_game_data.shoe_color = curr_shoe_color
		save_game_data.legs = curr_pants
		save_game_data.legs_color = curr_pants_color
		save_game_data.torso = curr_clothes
		save_game_data.torso_color = curr_clothes_color
		save_game_data.blush = curr_blush
		save_game_data.blush_color = curr_blush_color
		save_game_data.lipstick = curr_lipstick
		save_game_data.lipstick_color = curr_lipstick_color
		save_game_data.beard = curr_beard
		save_game_data.beard_color = curr_beard_color
		save_game_data.eyes = curr_eyes
		save_game_data.eyes_color = curr_eyes_color
		save_game_data.earring = curr_earring
		save_game_data.hairs = curr_hair
		save_game_data.hair_color = curr_hair_color
		save_game_data.mask = curr_mask
		save_game_data.glasses = curr_glasses
		save_game_data.hat = curr_hat
		save_game_data.name = charac_name
		save_game_data.id = uuid
		
		start_game()


func _on_HairLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_hair -= 1
	if curr_hair < 0:
		curr_hair = 13
	HairCountNode.set_text(str(curr_hair))
	if curr_hair == 0:
		hair.visible = false
		HairColorLeftNode.disabled = true
		HairColorRightNode.disabled = true
	else:
		hair.visible = true
		HairColorLeftNode.disabled = false
		HairColorRightNode.disabled = false
		scenePlayer.set_texture("curr_hair", curr_hair-1)


func _on_HairRight_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_hair += 1
	if curr_hair > 13:
		curr_hair = 0
	HairCountNode.set_text(str(curr_hair))
	if curr_hair == 0:
		hair.visible = false
		HairColorLeftNode.disabled = true
		HairColorRightNode.disabled = true
	else:
		hair.visible = true
		HairColorLeftNode.disabled = false
		HairColorRightNode.disabled = false
		scenePlayer.set_texture("curr_hair", curr_hair-1)


func _on_HairColorLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_hair_color = (curr_hair_color -1)
	if curr_hair_color < 0:
		curr_hair_color = 13
	reset_frame()
	scenePlayer.reset_key(9)
	scenePlayer._set_key(9, curr_hair_color*8)
	HairColorCountNode.set_text(str(curr_hair_color))


func _on_HairColorRight_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_hair_color = (curr_hair_color +1)
	if curr_hair_color > 13:
		curr_hair_color = 0
	reset_frame()
	scenePlayer.reset_key(9)
	scenePlayer._set_key(9, curr_hair_color*8)
	HairColorCountNode.set_text(str(curr_hair_color))


func _on_SkinLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	if curr_body > 0:
		curr_body = (curr_body -1)%8
	else:
		curr_body = 7
	SkinCountNode.set_text(str(curr_body))
	scenePlayer.set_texture("curr_body", curr_body)
	reset_frame()


func _on_SkinRight_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_body = (curr_body +1)%8
	SkinCountNode.set_text(str(curr_body))
	scenePlayer.set_texture("curr_body", curr_body)
	reset_frame()


func _on_TorsoLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_clothes -= 1
	if curr_clothes < 0:
		curr_clothes = 10
	TorsoCountNode.set_text(str(curr_clothes))
	scenePlayer.set_texture("curr_clothes", curr_clothes)


func _on_TorsoRight_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_clothes += 1
	if curr_clothes > 10:
		curr_clothes = 0
	TorsoCountNode.set_text(str(curr_clothes))
	scenePlayer.set_texture("curr_clothes", curr_clothes)


func _on_TorsoColorLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_clothes_color = (curr_clothes_color -1)
	if curr_clothes_color < 0:
		curr_clothes_color = 9
	reset_frame()
	scenePlayer.reset_key(3)
	scenePlayer._set_key(3, curr_clothes_color*8)
	TorsoColorCountNode.set_text(str(curr_clothes_color))


func _on_TorsoColorRight_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_clothes_color = (curr_clothes_color +1)
	if curr_clothes_color > 9:
		curr_clothes_color = 0
	reset_frame()
	scenePlayer.reset_key(3)
	scenePlayer._set_key(3, curr_clothes_color*8)
	TorsoColorCountNode.set_text(str(curr_clothes_color))


func _on_LegsLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_pants -= 1
	if curr_pants < 0:
		curr_pants = 2
	LegsCountNode.set_text(str(curr_pants))
	scenePlayer.set_texture("curr_pants", curr_pants)


func _on_LegsRight_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_pants += 1
	if curr_pants > 2:
		curr_pants = 0
	LegsCountNode.set_text(str(curr_pants))
	scenePlayer.set_texture("curr_pants", curr_pants)


func _on_LegsColorLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_pants_color = (curr_pants_color -1)
	if curr_pants_color < 0:
		curr_pants_color = 9
	reset_frame()
	scenePlayer.reset_key(2)
	scenePlayer._set_key(2, curr_pants_color*8)
	LegsColorCountNode.set_text(str(curr_pants_color))


func _on_LegsColorRight_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_pants_color = (curr_pants_color +1)
	if curr_pants_color > 9:
		curr_pants_color = 0
	reset_frame()
	scenePlayer.reset_key(2)
	scenePlayer._set_key(2, curr_pants_color*8)
	LegsColorCountNode.set_text(str(curr_pants_color))


func _on_ShoesLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_shoe_color = (curr_shoe_color -1)
	if curr_shoe_color < 0:
		curr_shoe_color = 9
	reset_frame()
	scenePlayer.reset_key(1)
	scenePlayer._set_key(1, curr_shoe_color*8)
	ShoesCountNode.set_text(str(curr_shoe_color))
	scenePlayer.set_texture("curr_shoes", curr_shoes)


func _on_ShoesRight_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_shoe_color = (curr_shoe_color +1)
	if curr_shoe_color > 9:
		curr_shoe_color = 0
	reset_frame()
	scenePlayer.reset_key(1)
	scenePlayer._set_key(1, curr_shoe_color*8)
	ShoesCountNode.set_text(str(curr_shoe_color))
	scenePlayer.set_texture("curr_shoes", curr_shoes)


func _on_EyesLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_eyes_color = (curr_eyes_color -1)
	if curr_eyes_color < 0:
		curr_eyes_color = 13
	reset_frame()
	scenePlayer.reset_key(7)
	scenePlayer._set_key(7, curr_eyes_color*8)
	EyesCountNode.set_text(str(curr_eyes_color))
	scenePlayer.set_texture("curr_eyes", curr_eyes)


func _on_EyesRight_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_eyes_color = (curr_eyes_color +1)
	if curr_eyes_color > 13:
		curr_eyes_color = 0
	reset_frame()
	scenePlayer.reset_key(7)
	scenePlayer._set_key(7, curr_eyes_color*8)
	EyesCountNode.set_text(str(curr_eyes_color))
	scenePlayer.set_texture("curr_eyes", curr_eyes)


func _on_MakeupLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_lipstick_color = (curr_lipstick_color -1)
	if curr_lipstick_color < 0:
		curr_lipstick_color = 5
	if curr_lipstick_color == 0:
		lipstick.visible = false
	else:
		reset_frame()
		scenePlayer.reset_key(5)
		scenePlayer._set_key(5, (curr_lipstick_color-1)*8)
		lipstick.visible = true
	scenePlayer.set_texture("curr_lipstick", curr_lipstick)
	
	curr_blush_color = (curr_blush_color -1)
	if curr_blush_color < 0:
		curr_blush_color = 5
	if curr_blush_color == 0:
		blush.visible = false
	else:
		reset_frame()
		scenePlayer.reset_key(4)
		scenePlayer._set_key(4, (curr_blush_color-1)*8)
		blush.visible = true
	scenePlayer.set_texture("curr_blush", curr_blush)
	MakeupCountNode.set_text(str(curr_lipstick_color))


func _on_MakeupRight_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_lipstick_color = (curr_lipstick_color +1)
	if curr_lipstick_color > 5:
		curr_lipstick_color = 0
	if curr_lipstick_color == 0:
		lipstick.visible = false
	else:
		reset_frame()
		scenePlayer.reset_key(5)
		scenePlayer._set_key(5, (curr_lipstick_color-1)*8)
		lipstick.visible = true
	scenePlayer.set_texture("curr_lipstick", curr_lipstick)
	
	curr_blush_color = (curr_blush_color +1)
	if curr_blush_color > 5:
		curr_blush_color = 0
	if curr_blush_color == 0:
		blush.visible = false
	else:
		reset_frame()
		scenePlayer.reset_key(4)
		scenePlayer._set_key(4, (curr_blush_color-1)*8)
		blush.visible = true
	scenePlayer.set_texture("curr_blush", curr_blush)
	MakeupCountNode.set_text(str(curr_lipstick_color))


func _on_BeardLeft_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_beard_color = (curr_beard_color -1)
	if curr_beard_color < 0:
		curr_beard_color = 14
	BeardCountNode.set_text(str(curr_beard_color))
	if curr_beard_color == 0:
		beard.visible = false
	else:
		beard.visible = true
		reset_frame()
		scenePlayer.reset_key(6)
		scenePlayer._set_key(6, (curr_beard_color-1)*8)
	scenePlayer.set_texture("curr_beard", curr_beard)


func _on_BeardRight_pressed(): 
	Utils.set_and_play_sound(Constants.PreloadedSounds.Choose)
	curr_beard_color = (curr_beard_color +1)
	if curr_beard_color > 14:
		curr_beard_color = 0
	BeardCountNode.set_text(str(curr_beard_color))
	if curr_beard_color == 0:
		beard.visible = false
	else:
		beard.visible = true
		reset_frame()
		scenePlayer.reset_key(6)
		scenePlayer._set_key(6, (curr_beard_color-1)*8)
	scenePlayer.set_texture("curr_beard", curr_beard)


func _on_LineEdit_text_changed(new_text):
	if new_text.length() > Constants.NAME_LENGTH:
		LineEditNode.delete_char_at_cursor()
	elif line_editRegEx.search(new_text):
		charac_name = str(new_text)
	else:
		if "  " in new_text:
			LineEditNode.delete_char_at_cursor()
		elif new_text == "":
			charac_name = ""
		elif new_text.begins_with(" "):
			LineEditNode.delete_text(0,1)
		elif new_text.ends_with(" "):
			charac_name = new_text
		else:
			LineEditNode.delete_char_at_cursor()
		
		if line_editRegEx.search(new_text):
			charac_name = new_text


func reset_frame():
	body.frame = 0
	shoes.frame = curr_shoe_color*8
	pants.frame = curr_pants_color*8
	clothes.frame = curr_clothes_color*8
	if curr_blush_color == 0:
		blush.frame = (curr_blush_color)*8
	else:
		blush.frame = (curr_blush_color-1)*8
	if curr_lipstick_color == 0:
		lipstick.frame = (curr_lipstick_color)*8
	else:
		lipstick.frame = (curr_lipstick_color-1)*8
	if curr_beard_color == 0:
		beard.frame = (curr_beard_color)*8
	else:
		beard.frame = (curr_beard_color-1)*8
	eyes.frame = curr_eyes_color*8
	hair.frame = curr_hair_color*8


# Disable movment of scenePlayer when type in name
func _on_LineEdit_focus_entered():
	scenePlayer.pause_player(true)


# Enable movment of scenePlayer when exiting the lineEdit
func _on_LineEdit_focus_exited():
	scenePlayer.pause_player(false)


# Method to start game scene
func start_game():
	# Set colors for attack animations
	set_colors_for_attack_anim()
	
	# Set colors for hurt animations
	set_colors_for_hurt_anim()
	
	# Set colors for die animations
	set_colors_for_die_anim()
	
	# Set colors for collect animations
	set_colors_for_collect_anim()
	
	# Set scenePlayer to current_player to use for other scenes
	Utils.set_current_player(scenePlayer)
	
	DayNightCycle.set_current_time(0.0)
	DayNightCycle.set_passed_days(0)
	
	Utils.get_current_player().set_data(save_game_data)
	
	FileManager.create_character(save_game_data)
	set_current_player_data()
	
	var transition_data = TransitionData.Menu.new(Constants.STORY_SCENE_PATH)
	Utils.get_scene_manager().transition_to_scene(transition_data)
	
	# Save game -> AT THE END OF THIS METHOD!
	Utils.save_game(true)


func set_current_player_data():
	# set scenePlayer data
	PlayerData.set_path(uuid)
	PlayerData.load_player_data()
	
	# set hotbar & light
	Utils.get_hotbar().load_hotbar()
	Utils.get_current_player().set_light(save_game_data.light)
	Utils.get_ui().has_map = save_game_data.has_map
	Utils.get_minimap().set_show_map(save_game_data.show_map)
	
	# sets lp & weapon
	Utils.get_current_player().set_max_health(save_game_data.maxLP)
	Utils.get_current_player().set_gold(save_game_data.gold)
	Utils.get_current_player().set_level(save_game_data.level)
	Utils.get_current_player().set_current_health(save_game_data.currentHP)
	Utils.get_current_player().set_max_stamina(save_game_data.maxStamina)
	Utils.get_current_player().set_current_stamina(save_game_data.stamina)
	Utils.get_player_ui().setup_ui()
	Utils.get_current_player().set_exp(save_game_data.exp)
	
	Utils.get_current_player().set_current_health(save_game_data.currentHP)
	var item_id = PlayerData.equipment_data["Weapon"]["Item"]
	Utils.get_current_player().set_weapon(item_id, save_game_data.attack, save_game_data.attack_speed, save_game_data.knockback)


# Method to set all colors/frames to attack animations
func set_colors_for_attack_anim():
	# set the ATTACK animation colors
	# Shoes
	scenePlayer.reset_attack_key("Shoes:frame")
	scenePlayer._set_attack_key("Shoes:frame", curr_shoe_color * 8)
	# Pants
	scenePlayer.reset_attack_key("Pants:frame")
	scenePlayer._set_attack_key("Pants:frame", curr_pants_color * 8)
	# Clothes
	scenePlayer.reset_attack_key("Clothes:frame")
	scenePlayer._set_attack_key("Clothes:frame", curr_clothes_color * 8)
	# Blush
	scenePlayer.reset_attack_key("Blush:frame")
	if curr_blush_color == 0:
		scenePlayer._set_attack_key("Blush:frame", curr_blush_color * 8)
	else: 
		scenePlayer._set_attack_key("Blush:frame", (curr_blush_color - 1) * 8)
	# Lipstick
	scenePlayer.reset_attack_key("Lipstick:frame")
	if curr_lipstick_color == 0:
		scenePlayer._set_attack_key("Lipstick:frame", curr_lipstick_color * 8)
	else: 
		scenePlayer._set_attack_key("Lipstick:frame", (curr_lipstick_color - 1) * 8)
	# Beard
	scenePlayer.reset_attack_key("Beard:frame")
	if curr_beard_color == 0:
		scenePlayer._set_attack_key("Beard:frame", curr_beard_color * 8)
	else: 
		scenePlayer._set_attack_key("Beard:frame", (curr_beard_color - 1) * 8)
	# Eyes
	scenePlayer.reset_attack_key("Eyes:frame")
	scenePlayer._set_attack_key("Eyes:frame", curr_eyes_color * 8)
	# Hairs
	scenePlayer.reset_attack_key("Hair:frame")
	scenePlayer._set_attack_key("Hair:frame", curr_hair_color * 8)


# Method to set all colors/frames to hurt animations
func set_colors_for_hurt_anim():
	# set the HURT animation colors
	# Shoes
	scenePlayer.reset_hurt_key("Shoes:frame")
	scenePlayer._set_hurt_key("Shoes:frame", curr_shoe_color * 8)
	# Pants
	scenePlayer.reset_hurt_key("Pants:frame")
	scenePlayer._set_hurt_key("Pants:frame", curr_pants_color * 8)
	# Clothes
	scenePlayer.reset_hurt_key("Clothes:frame")
	scenePlayer._set_hurt_key("Clothes:frame", curr_clothes_color * 8)
	# Blush
	scenePlayer.reset_hurt_key("Blush:frame")
	if curr_blush_color == 0:
		scenePlayer._set_hurt_key("Blush:frame", curr_blush_color * 8)
	else: 
		scenePlayer._set_hurt_key("Blush:frame", (curr_blush_color - 1) * 8)
	# Lipstick
	scenePlayer.reset_hurt_key("Lipstick:frame")
	if curr_lipstick_color == 0:
		scenePlayer._set_hurt_key("Lipstick:frame", curr_lipstick_color * 8)
	else: 
		scenePlayer._set_hurt_key("Lipstick:frame", (curr_lipstick_color - 1) * 8)
	# Beard
	scenePlayer.reset_hurt_key("Beard:frame")
	if curr_beard_color == 0:
		scenePlayer._set_hurt_key("Beard:frame", curr_beard_color * 8)
	else: 
		scenePlayer._set_hurt_key("Beard:frame", (curr_beard_color - 1) * 8)
	# Eyes
	scenePlayer.reset_hurt_key("Eyes:frame")
	scenePlayer._set_hurt_key("Eyes:frame", curr_eyes_color * 8)
	# Hairs
	scenePlayer.reset_hurt_key("Hair:frame")
	scenePlayer._set_hurt_key("Hair:frame", curr_hair_color * 8)


# Method to set all colors/frames to die animation
func set_colors_for_die_anim():
	# set the DIE animation colors
	# Shoes
	scenePlayer.reset_die_key("Shoes:frame")
	scenePlayer._set_die_key("Shoes:frame", curr_shoe_color * 8)
	# Pants
	scenePlayer.reset_die_key("Pants:frame")
	scenePlayer._set_die_key("Pants:frame", curr_pants_color * 8)
	# Clothes
	scenePlayer.reset_die_key("Clothes:frame")
	scenePlayer._set_die_key("Clothes:frame", curr_clothes_color * 8)
	# Blush
	scenePlayer.reset_die_key("Blush:frame")
	if curr_blush_color == 0:
		scenePlayer._set_die_key("Blush:frame", curr_blush_color * 8)
	else: 
		scenePlayer._set_die_key("Blush:frame", (curr_blush_color - 1) * 8)
	# Lipstick
	scenePlayer.reset_die_key("Lipstick:frame")
	if curr_lipstick_color == 0:
		scenePlayer._set_die_key("Lipstick:frame", curr_lipstick_color * 8)
	else: 
		scenePlayer._set_die_key("Lipstick:frame", (curr_lipstick_color - 1) * 8)
	# Beard
	scenePlayer.reset_die_key("Beard:frame")
	if curr_beard_color == 0:
		scenePlayer._set_die_key("Beard:frame", curr_beard_color * 8)
	else: 
		scenePlayer._set_die_key("Beard:frame", (curr_beard_color - 1) * 8)
	# Eyes
	scenePlayer.reset_die_key("Eyes:frame")
	scenePlayer._set_die_key("Eyes:frame", curr_eyes_color * 8)
	# Hairs
	scenePlayer.reset_die_key("Hair:frame")
	scenePlayer._set_die_key("Hair:frame", curr_hair_color * 8)


# Method to set all colors/frames to collect animations
func set_colors_for_collect_anim():
	# set the collect animation colors
	# Shoes
	scenePlayer.reset_collect_key("Shoes:frame")
	scenePlayer._set_collect_key("Shoes:frame", curr_shoe_color * 8)
	# Pants
	scenePlayer.reset_collect_key("Pants:frame")
	scenePlayer._set_collect_key("Pants:frame", curr_pants_color * 8)
	# Clothes
	scenePlayer.reset_collect_key("Clothes:frame")
	scenePlayer._set_collect_key("Clothes:frame", curr_clothes_color * 8)
	# Blush
	scenePlayer.reset_collect_key("Blush:frame")
	if curr_blush_color == 0:
		scenePlayer._set_collect_key("Blush:frame", curr_blush_color * 8)
	else: 
		scenePlayer._set_collect_key("Blush:frame", (curr_blush_color - 1) * 8)
	# Lipstick
	scenePlayer.reset_collect_key("Lipstick:frame")
	if curr_lipstick_color == 0:
		scenePlayer._set_collect_key("Lipstick:frame", curr_lipstick_color * 8)
	else: 
		scenePlayer._set_collect_key("Lipstick:frame", (curr_lipstick_color - 1) * 8)
	# Beard
	scenePlayer.reset_collect_key("Beard:frame")
	if curr_beard_color == 0:
		scenePlayer._set_collect_key("Beard:frame", curr_beard_color * 8)
	else: 
		scenePlayer._set_collect_key("Beard:frame", (curr_beard_color - 1) * 8)
	# Eyes
	scenePlayer.reset_collect_key("Eyes:frame")
	scenePlayer._set_collect_key("Eyes:frame", curr_eyes_color * 8)
	# Hairs
	scenePlayer.reset_collect_key("Hair:frame")
	scenePlayer._set_collect_key("Hair:frame", curr_hair_color * 8)


# Method to check if pos is inside or outside of LineEditNode
func is_pos_in_line_edit(pos: Vector2):
	var global_rect = LineEditNode.get_global_rect()
	var is_inside = pos.x >= global_rect.position.x \
		and pos.y >= global_rect.position.y \
		and pos.x <= global_rect.end.x \
		and pos.y <= global_rect.end.y
	return is_inside


func _input(event):
	if event is InputEventMouseButton:
		# Check if mouse click is inside or outside of LineEditNode to release focus if click is outside
		if characterSettingsContainer.get_focus_owner() == LineEditNode:
			# Release focus if click is outside of LineEditNode
			if not is_pos_in_line_edit(event.position):
				LineEditNode.release_focus()
