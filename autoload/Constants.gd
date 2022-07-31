extends Node

# Tiles
const tile_size = 16

# Chunks
const chunk_size_tiles = 10 # In tiles
const chunk_size_pixel = chunk_size_tiles * tile_size # In pixel

# Player
const PLAYER_WALK_SPEED = 70
const PLAYER_TRANSFORM_SCALE = 0.9
const PLAYER_MAX_LIGHT_ENERGY = 0.8
const PLAYER_STAIR_SPEED_FACTOR = 0.6

# Transition
enum TransitionType {
	GAME_SCENE,
	MENU_SCENE
}

# Scene info
enum SceneType {
	MENU,
	CAMP,
	GRASSLAND,
	DUNGEON
}

# Spawn time
enum SpawnTime {
	ONLY_DAY,
	ONLY_NIGHT,
	ALWAYS
}

# Darkness lights environment
const DAY_COLOR = Color("ffffff")
const SUNSET_COLOR = Color("ff8f53")
const NIGHT_COLOR = Color("212121")
const SUNRISE_COLOR = Color("ff8f53")
const DUNGEON_COLOR = Color("000000")

# NPC Walk Speed
const NPC_NORMAL_SPEED = 30
const NPC_STAIRS_SPEED = NPC_NORMAL_SPEED*0.6

# Pathes
const MENU_FOLDER = "res://scenes/menu/"
const CAMP_FOLDER = "res://scenes/camp/"
const GRASSLAND_FOLDER = "res://scenes/grassland/"
const DUNGEONS_FOLDER = "res://scenes/dungeons/"

const MAIN_MENU_PATH = "res://scenes/menu/MainMenuScreen.tscn"
const CHARACTER_SCREEN_PATH = "res://scenes/menu/character_screens/CharacterScreen.tscn"
const CHARACTER_SCREEN_CONTAINER_SCRIPT_PATH = "res://scenes/menu/character_screens/CharacterScreenContainerScript.gd"
const CREATE_CHARACTER_SCREEN_PATH = "res://scenes/menu/character_screens/CreateCharacter.tscn"
const GAME_MENU_PATH = "res://scenes/menu/GameMenu.tscn"
const SETTINGS_PATH = "res://scenes/menu/SettingScreen.tscn"
const SAVE_SETTINGS_PATH = "user://settings.json"
const TRADE_INVENTORY_PATH = "res://scenes/inventory/TradeInventory.tscn"
const ITEM_DATA_PATH = "res://assets/data/ItemData.json"
const CAMP_SCENE_PATH = "res://scenes/camp/Camp.tscn"
const GRASSLAND_SCENE_PATH = "res://scenes/grassland/Grassland.tscn"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
