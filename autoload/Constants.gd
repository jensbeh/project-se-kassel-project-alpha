extends Node


const PLAYER_WALK_SPEED = 70

const PLAYER_TRANSFORM_SCALE = 0.9

enum TransitionType {
	GAME_SCENE,
	MENU_SCENE
}

enum SceneType {
	MENU,
	CAMP,
	GRASSLAND,
	DUNGEON
}

const MENU_FOLDER = "res://scenes/menu/"
const CAMP_FOLDER = "res://scenes/camp/"
const GRASSLAND_FOLDER = "res://scenes/grassland/"
const DUNGEONS_FOLDER = "res://scenes/dungeons/"

const MAIN_MENU_PATH = "res://scenes/menu/MainMenuScreen.tscn"
const CHARACTER_SCREEN_PATH = "res://scenes/menu/character_screens/CharacterScreen.tscn"
const CHARACTER_SCREEN_CONTAINER_SCRIPT_PATH = "res://scenes/menu/character_screens/CharacterScreenContainerScript.gd"
const CREATE_CHARACTER_SCREEN_PATH = "res://scenes/menu/character_screens/CreateCharacter.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
