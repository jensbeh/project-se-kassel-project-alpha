extends Node2D

const SAVE_PATH = "user://"
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


func _ready():
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

	get_sprites()
	
	
	
	beard.visible = false
	blush.visible = false
	lipstick.visible = false
	hair.visible = false
	
	uuid = uuid_util.v4()


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


var save_game_data = {
	"name": charac_name,
	"level": "1",
	"maxLP": "100",
	"currentHP": "100",
	"gold": "0",
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


# save the player data
func save_data():
	var save_game = File.new()
	save_game.open(SAVE_PATH + uuid + SAVE_FILE_EXTENSION, File.WRITE)
	save_game.store_line(to_json(save_game_data))
	save_game.close()
	print("Savegame saved")


func _on_Back_pressed():
	Utils.get_scene_manager().transition_to_scene("res://scenes/CharacterScreen.tscn")


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
		# Load Created Settings in World
		Utils.get_scene_manager().transition_to_scene("res://scenes/Camp.tscn")
		Utils.get_player().set_texture("curr_body", curr_body)
		Utils.get_player().set_texture("curr_clothes", curr_clothes)
		Utils.get_player().set_texture("curr_pants", curr_pants)
		Utils.get_player()._set_key(9, curr_hair_color*8)
		Utils.get_player()._set_key(3, curr_clothes_color*8)
		Utils.get_player()._set_key(2, curr_pants_color*8)
		Utils.get_player()._set_key(1, curr_shoe_color*8)
		Utils.get_player()._set_key(7, curr_eyes_color*8)
		if curr_beard_color == 0:
			Utils.get_player().set_visibility("Beard", false)
			Utils.get_player()._set_key(6, curr_beard_color*8)
		else: 
			Utils.get_player().set_visibility("Beard", true)
			Utils.get_player()._set_key(6, (curr_beard_color-1)*8)
		if curr_blush_color == 0:
			Utils.get_player().set_visibility("Blush", false)
			Utils.get_player()._set_key(4, curr_blush_color*8)
		else: 
			Utils.get_player().set_visibility("Blush", true)
			Utils.get_player()._set_key(4, (curr_blush_color-1)*8)
		if curr_lipstick_color == 0:
			Utils.get_player().set_visibility("Lipstick", false)
			Utils.get_player()._set_key(5, curr_lipstick_color*8)
		else: 
			Utils.get_player().set_visibility("Lipstick", true)
			Utils.get_player()._set_key(5, (curr_lipstick_color-1)*8)
		if curr_hair == 0:
			Utils.get_player().set_visibility("Hair", false)
			Utils.get_player().set_texture("curr_hair", curr_hair)
		else: 
			Utils.get_player().set_visibility("Hair", true)
			Utils.get_player().set_texture("curr_hair", curr_hair-1)
	

func _on_HairLeft_pressed():
	curr_hair -= 1
	if curr_hair < 0:
		curr_hair = 14
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer/HairCount.set_text(str(curr_hair))
	if curr_hair == 0:
		hair.visible = false
	else:
		hair.visible = true
		player.set_texture("curr_hair", curr_hair-1)


func _on_HairRight_pressed():
	curr_hair += 1
	if curr_hair > 14:
		curr_hair = 0
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer/HairCount.set_text(str(curr_hair))
	if curr_hair == 0:
		hair.visible = false
	else:
		hair.visible = true
		player.set_texture("curr_hair", curr_hair-1)


func _on_HairColorLeft_pressed():
	curr_hair_color = (curr_hair_color -1)
	if curr_hair_color < 0:
		curr_hair_color = 13
	hair.frame = (curr_hair_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorCount.set_text(str(curr_hair_color))


func _on_HairColorRight_pressed():
	curr_hair_color = (curr_hair_color +1)
	if curr_hair_color > 13:
		curr_hair_color = 0
	hair.frame = (curr_hair_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer2/HairColorCount.set_text(str(curr_hair_color))


func _on_SkinLeft_pressed():
	if curr_body > 0:
		curr_body = (curr_body -1)%8
	else:
		curr_body = 7
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer1/MarginContainer/VBoxContainer/HBoxContainer/SkinCount.set_text(str(curr_body))
	player.set_texture("curr_body", curr_body)


func _on_SkinRight_pressed():
	curr_body = (curr_body +1)%8
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer1/MarginContainer/VBoxContainer/HBoxContainer/SkinCount.set_text(str(curr_body))
	player.set_texture("curr_body", curr_body)


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
	clothes.frame = (curr_clothes_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer3/MarginContainer/VBoxContainer/HBoxContainer2/TorsoColorCount.set_text(str(curr_clothes_color))


func _on_TorsoColorRight_pressed():
	curr_clothes_color = (curr_clothes_color +1)
	if curr_clothes_color > 9:
		curr_clothes_color = 0
	clothes.frame = (curr_clothes_color*8)
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
	pants.frame = (curr_pants_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer4/MarginContainer/VBoxContainer/HBoxContainer2/LegsColorCount.set_text(str(curr_pants_color))


func _on_LegsColorRight_pressed():
	curr_pants_color = (curr_pants_color +1)
	if curr_pants_color > 9:
		curr_pants_color = 0
	pants.frame = (curr_pants_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer4/MarginContainer/VBoxContainer/HBoxContainer2/LegsColorCount.set_text(str(curr_pants_color))


func _on_ShoesLeft_pressed():
	curr_shoe_color = (curr_shoe_color -1)
	if curr_shoe_color < 0:
		curr_shoe_color = 9
	shoes.frame = (curr_shoe_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer5/MarginContainer/VBoxContainer/HBoxContainer/ShoesCount.set_text(str(curr_shoe_color))
	player.set_texture("curr_shoes", curr_shoes)


func _on_ShoesRight_pressed():
	curr_shoe_color = (curr_shoe_color +1)
	if curr_shoe_color > 9:
		curr_shoe_color = 0
	shoes.frame = (curr_shoe_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer5/MarginContainer/VBoxContainer/HBoxContainer/ShoesCount.set_text(str(curr_shoe_color))
	player.set_texture("curr_shoes", curr_shoes)


func _on_EyesLeft_pressed():
	curr_eyes_color = (curr_eyes_color -1)
	if curr_eyes_color < 0:
		curr_eyes_color = 13
	eyes.frame = (curr_eyes_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer6/MarginContainer/VBoxContainer/HBoxContainer/EyesCount.set_text(str(curr_eyes_color))
	player.set_texture("curr_eyes", curr_eyes)


func _on_EyesRight_pressed():
	curr_eyes_color = (curr_eyes_color +1)
	if curr_eyes_color > 13:
		curr_eyes_color = 0
	eyes.frame = (curr_eyes_color*8)
	$ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer6/MarginContainer/VBoxContainer/HBoxContainer/EyesCount.set_text(str(curr_eyes_color))
	player.set_texture("curr_eyes", curr_eyes)


func _on_MakeupLeft_pressed():
	curr_lipstick_color = (curr_lipstick_color -1)
	if curr_lipstick_color < 0:
		curr_lipstick_color = 5
	if curr_lipstick_color == 0:
		lipstick.visible = false
	else:
		lipstick.frame = ((curr_lipstick_color-1)*8)
		lipstick.visible = true
	player.set_texture("curr_lipstick", curr_lipstick)
	
	curr_blush_color = (curr_blush_color -1)
	if curr_blush_color < 0:
		curr_blush_color = 5
	if curr_blush_color == 0:
		blush.visible = false
	else:
		blush.frame = ((curr_blush_color-1)*8)
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
		lipstick.frame = ((curr_lipstick_color-1)*8)
		lipstick.visible = true
	player.set_texture("curr_lipstick", curr_lipstick)
	
	curr_blush_color = (curr_blush_color +1)
	if curr_blush_color > 5:
		curr_blush_color = 0
	if curr_blush_color == 0:
		blush.visible = false
	else:
		blush.visible = true
		blush.frame = ((curr_blush_color-1)*8)
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
		beard.frame = ((curr_beard_color-1)*8)
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
		beard.frame = ((curr_beard_color-1)*8)	
	player.set_texture("curr_beard", curr_beard)


func _on_LineEdit_text_changed(new_text):
	charac_name = new_text


