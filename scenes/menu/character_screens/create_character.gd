extends Node2D

const SAVE_PATH = "user://character/"
const SAVE_FILE_EXTENSION = ".json"
const uuid_util = preload("res://addons/uuid.gd")

onready var player = Utils.get_player()

var uuid
var charac_name = ""
# Count Textures, Count Colors
var curr_body: int = 0
var curr_shoes: int = 0
var curr_shoe_color: int = 0
var curr_pants: int = 0
var curr_pants_color: int = 0
var curr_clothes: int = 0
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
var curr_hair: int = 0
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

func _ready():
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
	
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer/HairCount.set_text(str(0))
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer1/MarginContainer/VBoxContainer/HBoxContainer/SkinCount.set_text(str(0))
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer3/MarginContainer/VBoxContainer/HBoxContainer/TorsoCount.set_text(str(0))
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer4/MarginContainer/VBoxContainer/HBoxContainer/LegsCount.set_text(str(0))
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer5/MarginContainer/VBoxContainer/HBoxContainer/ShoesCount.set_text(str(0))
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer6/MarginContainer/VBoxContainer/HBoxContainer/EyesCount.set_text(str(0))
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer8/MarginContainer/VBoxContainer/HBoxContainer/BeardCount.set_text(str(0))
	$ScrollContainer/MarginContainer/VBoxContainer/MarginContainer7/MarginContainer/VBoxContainer/HBoxContainer/MakeupCount.set_text(str(0))
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorCount.set_text(str(0))
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer3/MarginContainer/VBoxContainer/HBoxContainer2/TorsoColorCount.set_text(str(0))
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer4/MarginContainer/VBoxContainer/HBoxContainer2/LegsColorCount.set_text(str(0))

	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorLeft.disabled = true
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorRight.disabled = true

	get_sprites()
	
	Utils.get_player().set_movement(false)
	
	beard.visible = false
	blush.visible = false
	lipstick.visible = false
	hair.visible = false
	shadow.visible = true
	
	uuid = uuid_util.v4()
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()


func get_sprites():
	for child in Utils.get_player().get_children():
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
	"level": "1",
	"maxLP": "100",
	"currentHP": "100",
	"gold": "100",
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
	"id" : uuid
}

var save_inventory = {
	"Inv1": {"Item": null,"Stack": null},
	"Inv2": {"Item": null,"Stack": null},
	"Inv3": {"Item": null,"Stack": null},
	"Inv4": {"Item": null,"Stack": null},
	"Inv5": {"Item": null,"Stack": null},
	"Inv6": {"Item": null,"Stack": null},
	"Inv7": {"Item": null,"Stack": null},
	"Inv8": {"Item": null,"Stack": null},
	"Inv9": {"Item": null,"Stack": null},
	"Inv10": {"Item": null,"Stack": null},
	"Inv11": {"Item": null,"Stack": null},
	"Inv12": {"Item": null,"Stack": null},
	"Inv13": {"Item": null,"Stack": null},
	"Inv14": {"Item": null,"Stack": null},
	"Inv15": {"Item": null,"Stack": null},
	"Inv16": {"Item": null,"Stack": null},
	"Inv17": {"Item": null,"Stack": null},
	"Inv18": {"Item": null,"Stack": null},
	"Inv19": {"Item": null,"Stack": null},
	"Inv20": {"Item": null,"Stack": null},
	"Inv21": {"Item": null,"Stack": null},
	"Inv22": {"Item": null,"Stack": null},
	"Inv23": {"Item": null,"Stack": null},
	"Inv24": {"Item": null,"Stack": null},
	"Inv25": {"Item": null,"Stack": null},
	"Inv26": {"Item": null,"Stack": null},
	"Inv27": {"Item": null,"Stack": null},
	"Inv28": {"Item": null,"Stack": null},
	"Inv29": {"Item": null,"Stack": null},
	"Inv30": {"Item": null,"Stack": null},
}

# save the player data
func save_data():
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_PATH):
		dir.make_dir(SAVE_PATH)
	var save_game = File.new()
	save_game.open(SAVE_PATH + uuid + SAVE_FILE_EXTENSION, File.WRITE)
	save_game.store_line(to_json(save_game_data))
	save_game.close()
	print("Savegame saved")


func _on_Back_pressed():
	var transition_data = TransitionData.Menu.new(Constants.CHARACTER_SCREEN_PATH)
	Utils.get_scene_manager().transition_to_scene(transition_data)


func _on_Create_Character_pressed():
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
		save_data()

		start_game()
		
func _on_HairLeft_pressed():
	curr_hair -= 1
	if curr_hair < 0:
		curr_hair = 13
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer/HairCount.set_text(str(curr_hair))
	if curr_hair == 0:
		hair.visible = false
		$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorLeft.disabled = true
		$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorRight.disabled = true
	else:
		hair.visible = true
		$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorLeft.disabled = false
		$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorRight.disabled = false
		player.set_texture("curr_hair", curr_hair-1)


func _on_HairRight_pressed():
	curr_hair += 1
	if curr_hair > 13:
		curr_hair = 0
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer/HairCount.set_text(str(curr_hair))
	if curr_hair == 0:
		hair.visible = false
		$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorLeft.disabled = true
		$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorRight.disabled = true
	else:
		hair.visible = true
		$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorLeft.disabled = false
		$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorRight.disabled = false
		player.set_texture("curr_hair", curr_hair-1)


func _on_HairColorLeft_pressed():
	curr_hair_color = (curr_hair_color -1)
	if curr_hair_color < 0:
		curr_hair_color = 13
	player.reset_key(9)
	player._set_key(9, curr_hair_color*8)
	reset_frame()
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorCount.set_text(str(curr_hair_color))


func _on_HairColorRight_pressed():
	curr_hair_color = (curr_hair_color +1)
	if curr_hair_color > 13:
		curr_hair_color = 0
	player.reset_key(9)
	player._set_key(9, curr_hair_color*8)
	reset_frame()
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorCount.set_text(str(curr_hair_color))


func _on_SkinLeft_pressed():
	if curr_body > 0:
		curr_body = (curr_body -1)%8
	else:
		curr_body = 7
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer1/MarginContainer/VBoxContainer/HBoxContainer/SkinCount.set_text(str(curr_body))
	player.set_texture("curr_body", curr_body)
	reset_frame()


func _on_SkinRight_pressed():
	curr_body = (curr_body +1)%8
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer1/MarginContainer/VBoxContainer/HBoxContainer/SkinCount.set_text(str(curr_body))
	player.set_texture("curr_body", curr_body)
	reset_frame()


func _on_TorsoLeft_pressed():
	curr_clothes -= 1
	if curr_clothes < 0:
		curr_clothes = 10
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer3/MarginContainer/VBoxContainer/HBoxContainer/TorsoCount.set_text(str(curr_clothes))
	player.set_texture("curr_clothes", curr_clothes)


func _on_TorsoRight_pressed():
	curr_clothes += 1
	if curr_clothes > 10:
		curr_clothes = 0
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer3/MarginContainer/VBoxContainer/HBoxContainer/TorsoCount.set_text(str(curr_clothes))
	player.set_texture("curr_clothes", curr_clothes)


func _on_TorsoColorLeft_pressed():
	curr_clothes_color = (curr_clothes_color -1)
	if curr_clothes_color < 0:
		curr_clothes_color = 9
	player.reset_key(3)
	player._set_key(3, curr_clothes_color*8)
	reset_frame()
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer3/MarginContainer/VBoxContainer/HBoxContainer2/TorsoColorCount.set_text(str(curr_clothes_color))


func _on_TorsoColorRight_pressed():
	curr_clothes_color = (curr_clothes_color +1)
	if curr_clothes_color > 9:
		curr_clothes_color = 0
	player.reset_key(3)
	player._set_key(3, curr_clothes_color*8)
	reset_frame()
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer3/MarginContainer/VBoxContainer/HBoxContainer2/TorsoColorCount.set_text(str(curr_clothes_color))


func _on_LegsLeft_pressed():
	curr_pants -= 1
	if curr_pants < 0:
		curr_pants = 2
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer4/MarginContainer/VBoxContainer/HBoxContainer/LegsCount.set_text(str(curr_pants))
	player.set_texture("curr_pants", curr_pants)


func _on_LegsRight_pressed():
	curr_pants += 1
	if curr_pants > 2:
		curr_pants = 0
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer4/MarginContainer/VBoxContainer/HBoxContainer/LegsCount.set_text(str(curr_pants))
	player.set_texture("curr_pants", curr_pants)


func _on_LegsColorLeft_pressed():
	curr_pants_color = (curr_pants_color -1)
	if curr_pants_color < 0:
		curr_pants_color = 9
	player.reset_key(2)
	player._set_key(2, curr_pants_color*8)
	reset_frame()
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer4/MarginContainer/VBoxContainer/HBoxContainer2/LegsColorCount.set_text(str(curr_pants_color))


func _on_LegsColorRight_pressed():
	curr_pants_color = (curr_pants_color +1)
	if curr_pants_color > 9:
		curr_pants_color = 0
	player.reset_key(2)
	player._set_key(2, curr_pants_color*8)
	reset_frame()
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer4/MarginContainer/VBoxContainer/HBoxContainer2/LegsColorCount.set_text(str(curr_pants_color))


func _on_ShoesLeft_pressed():
	curr_shoe_color = (curr_shoe_color -1)
	if curr_shoe_color < 0:
		curr_shoe_color = 9
	reset_frame()
	player.reset_key(1)
	player._set_key(1, curr_shoe_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer5/MarginContainer/VBoxContainer/HBoxContainer/ShoesCount.set_text(str(curr_shoe_color))
	player.set_texture("curr_shoes", curr_shoes)


func _on_ShoesRight_pressed():
	curr_shoe_color = (curr_shoe_color +1)
	if curr_shoe_color > 9:
		curr_shoe_color = 0
	reset_frame()
	player.reset_key(1)
	player._set_key(1, curr_shoe_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer5/MarginContainer/VBoxContainer/HBoxContainer/ShoesCount.set_text(str(curr_shoe_color))
	player.set_texture("curr_shoes", curr_shoes)


func _on_EyesLeft_pressed():
	curr_eyes_color = (curr_eyes_color -1)
	if curr_eyes_color < 0:
		curr_eyes_color = 13
	reset_frame()
	player.reset_key(7)
	player._set_key(7, curr_eyes_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer6/MarginContainer/VBoxContainer/HBoxContainer/EyesCount.set_text(str(curr_eyes_color))
	player.set_texture("curr_eyes", curr_eyes)


func _on_EyesRight_pressed():
	curr_eyes_color = (curr_eyes_color +1)
	if curr_eyes_color > 13:
		curr_eyes_color = 0
	reset_frame()
	player.reset_key(7)
	player._set_key(7, curr_eyes_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer6/MarginContainer/VBoxContainer/HBoxContainer/EyesCount.set_text(str(curr_eyes_color))
	player.set_texture("curr_eyes", curr_eyes)


func _on_MakeupLeft_pressed():
	curr_lipstick_color = (curr_lipstick_color -1)
	if curr_lipstick_color < 0:
		curr_lipstick_color = 5
	if curr_lipstick_color == 0:
		lipstick.visible = false
	else:
		player.reset_key(5)
		player._set_key(5, (curr_lipstick_color-1)*8)
		reset_frame()
		lipstick.visible = true
	player.set_texture("curr_lipstick", curr_lipstick)
	
	curr_blush_color = (curr_blush_color -1)
	if curr_blush_color < 0:
		curr_blush_color = 5
	if curr_blush_color == 0:
		blush.visible = false
	else:
		player.reset_key(4)
		player._set_key(4, (curr_blush_color-1)*8)
		reset_frame()
		blush.visible = true
	player.set_texture("curr_blush", curr_blush)
	$ScrollContainer/MarginContainer/VBoxContainer/MarginContainer7/MarginContainer/VBoxContainer/HBoxContainer/MakeupCount.set_text(str(curr_lipstick_color))


func _on_MakeupRight_pressed():
	curr_lipstick_color = (curr_lipstick_color +1)
	if curr_lipstick_color > 5:
		curr_lipstick_color = 0
	if curr_lipstick_color == 0:
		lipstick.visible = false
	else:
		player.reset_key(5)
		player._set_key(5, (curr_lipstick_color-1)*8)
		reset_frame()
		lipstick.visible = true
	player.set_texture("curr_lipstick", curr_lipstick)
	
	curr_blush_color = (curr_blush_color +1)
	if curr_blush_color > 5:
		curr_blush_color = 0
	if curr_blush_color == 0:
		blush.visible = false
	else:
		player.reset_key(4)
		player._set_key(4, (curr_blush_color-1)*8)
		blush.visible = true
		reset_frame()
	player.set_texture("curr_blush", curr_blush)
	$ScrollContainer/MarginContainer/VBoxContainer/MarginContainer7/MarginContainer/VBoxContainer/HBoxContainer/MakeupCount.set_text(str(curr_lipstick_color))


func _on_BeardLeft_pressed():
	curr_beard_color = (curr_beard_color -1)
	if curr_beard_color < 0:
		curr_beard_color = 14
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer8/MarginContainer/VBoxContainer/HBoxContainer/BeardCount.set_text(str(curr_beard_color))
	if curr_beard_color == 0:
		beard.visible = false
	else:
		beard.visible = true
		player.reset_key(6)
		player._set_key(6, (curr_beard_color-1)*8)
		reset_frame()
	player.set_texture("curr_beard", curr_beard)


func _on_BeardRight_pressed(): 
	curr_beard_color = (curr_beard_color +1)
	if curr_beard_color > 14:
		curr_beard_color = 0
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer8/MarginContainer/VBoxContainer/HBoxContainer/BeardCount.set_text(str(curr_beard_color))
	if curr_beard_color == 0:
		beard.visible = false
	else:
		beard.visible = true
		player.reset_key(6)
		player._set_key(6, (curr_beard_color-1)*8)
		reset_frame()
	player.set_texture("curr_beard", curr_beard)


func _on_LineEdit_text_changed(new_text):
	if new_text.length() > 28:
		$ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/MarginContainer/VBoxContainer/LineEdit.delete_char_at_cursor()
	else:
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

# Disable movment of player when type in name
func _on_LineEdit_focus_entered():
	Utils.get_player().set_movment_animation(false)

# Enable movment of player when exiting the lineEdit
func _on_LineEdit_focus_exited():
	Utils.get_player().set_movment_animation(true)


func start_game():
	# Set current player to use for other scenes
	Utils.set_current_player(Utils.get_player())
	var player_position = Vector2(1128,616)
	var view_direction = Vector2(0,1)
	create_player_inventory()
	
	Utils.get_current_player().set_gold(save_game_data.gold)
	
	var transition_data = TransitionData.GamePosition.new(Constants.CAMP_FOLDER + "/Camp.tscn", player_position, view_direction)
	Utils.get_scene_manager().transition_to_scene(transition_data)

func create_player_inventory():
	var save_player = File.new()
	save_player.open("res://assets/data/" + uuid + "_inv_data" + SAVE_FILE_EXTENSION, File.WRITE)
	save_player.store_line(to_json(save_inventory))
	save_player.close()
	PlayerData.set_path(uuid)
	PlayerData._ready()
