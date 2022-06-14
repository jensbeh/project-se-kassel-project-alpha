extends Node2D

const SAVE_PATH = "user://"
const SAVE_FILE_EXTENSION = ".json"

#onready var player = $ViewportContainer/Viewport/Player
onready var player = get_node("ViewportContainer/Viewport/Player")

var charac_name = ""
# Count Textures, Count Colors
var curr_body: int = 0 #0-8, 1
var curr_shoes: int = 0 #0, 10
var curr_pants: int = 0 #0-2, 10
var curr_clothes: int = 0 #0-10, 10 -> not by everyone
var curr_blush: int = 0 #0, 5
var curr_lipstick: int = 0 #0, 5
var curr_beard: int = 0 #0, 14
var curr_eyes: int = 0 #0, 14
var curr_earring: int = 0 #0-3, 1
var curr_hair: int = 8 #0-14, 14
var curr_mask: int = 0 #0-2, 1
var curr_glasses: int = 0 #0-1, 10
var curr_hat: int = 0 #0-4, 1

func _ready():
	pass # Replace with function body.
	
var save_game_data = {
	"name" : "",
	"level" : "",
	"maxLP" : "",
	"currentHP" : "",
	"gold" : "",
	"skincolor" : "",
	"hairs" : "",
	"torso" : "",
	"legs" : "",
	"eyes" : "",
	"shoes" : "",
	"make-up" : "",
	"beard" : "",
	"hat" : "",
	"mask" : "",
	"earrings" : "",
	"glasses" : "",
}


# loaded the player data
func load_data():
	var save_game = File.new()
	if not save_game.file_exists(SAVE_PATH + charac_name + SAVE_FILE_EXTENSION):
		print("no saves found")
	save_game.open(SAVE_PATH + charac_name + SAVE_FILE_EXTENSION, File.READ)
	save_game_data = parse_json(save_game.get_line())
	print("Savegame loaded", save_game_data)


# save the player data
func save_data():
	var save_game = File.new()
	save_game.open(SAVE_PATH + charac_name + SAVE_FILE_EXTENSION, File.WRITE)
	save_game.store_line(to_json(save_game_data))
	save_game.close()
	print("Savegame saved")


func _on_Back_pressed():
	Utils.get_scene_manager().transition_to_scene("res://scenes/CharacterScreen.tscn")


func _on_Create_Character_pressed():
	Utils.get_scene_manager().transition_to_scene("res://scenes/Camp.tscn")
	save_data()


func _on_HairLeft_pressed():
	curr_hair = (curr_hair -1)%15
	player.set_texture("curr_hair", curr_hair)


func _on_HairRight_pressed():
	curr_hair = (curr_hair +1)%15
	player.set_texture("curr_hair", curr_hair)


func _on_SkinLeft_pressed():
	curr_body = (curr_body -1)%9
	player.set_texture("curr_body", curr_body)


func _on_SkinRight_pressed():
	curr_body = (curr_body +1)%9
	player.set_texture("curr_body", curr_body)


func _on_TorsoLeft_pressed():
	curr_clothes = (curr_clothes -1)%11
	player.set_texture("curr_clothes", curr_clothes)


func _on_TorsoRight_pressed():
	curr_clothes = (curr_clothes +1)%11
	player.set_texture("curr_clothes", curr_clothes)


func _on_LegsLeft_pressed():
	curr_pants = (curr_pants -1)%3
	player.set_texture("curr_pants", curr_pants)


func _on_LegsRight_pressed():
	curr_pants = (curr_pants +1)%3
	player.set_texture("curr_pants", curr_pants)


func _on_ShoesLeft_pressed():
	curr_shoes = (curr_shoes -1)%1
	player.set_texture("curr_shoes", curr_shoes)


func _on_ShoesRight_pressed():
	curr_shoes = (curr_shoes +1)%1
	player.set_texture("curr_shoes", curr_shoes)


func _on_EyesLeft_pressed():
	curr_eyes = (curr_eyes -1)%1
	player.set_texture("curr_eyes", curr_eyes)


func _on_EyesRight_pressed():
	curr_eyes = (curr_eyes +1)%1
	player.set_texture("curr_eyes", curr_eyes)


func _on_MakeupLeft_pressed():
	curr_lipstick = (curr_lipstick -1)%1
	player.set_texture("curr_lipstick", curr_lipstick)
	curr_blush = (curr_blush -1)%1
	player.set_texture("curr_blush", curr_blush)


func _on_MakeupRight_pressed():
	curr_lipstick = (curr_lipstick +1)%1
	player.set_texture("curr_lipstick", curr_lipstick)
	curr_blush = (curr_blush +1)%1
	player.set_texture("curr_blush", curr_blush)


func _on_BeardLeft_pressed():
	curr_beard = (curr_beard -1)%1
	player.set_texture("curr_beard", curr_beard)


func _on_BeardRight_pressed():
	curr_beard = (curr_beard +1)%1
	player.set_texture("curr_beard", curr_beard)

