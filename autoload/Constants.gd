extends Node


# --------------------------------------------------

# DEBUG
const SHOW_MOB_PATHES = true

# --------------------------------------------------

# Variables
const NAME_LENGTH = 15
const COOLDOWN = 20
const LOOTING_TIME = 60
const LOOT_CHANCE = 0.7 # means 70% Chance

# Tiles
const TILE_SIZE = 16
const PSEUDO_OBSTACLE_TILE_ID = 22
const PSEUDO_OBSTACLE_TILE_ID_DUNGEONS = 39
const INVALID_TILE_ID = -1

# Chunks
const CHUNK_SIZE_TILES = 10 # In tiles -> if changing need reimport of maps!
const chunk_size_pixel = CHUNK_SIZE_TILES * TILE_SIZE # In pixel
const RENDER_DISTANCE = 3 # Loaded chunks each direction except the one where the player stands -> min 3 !!!

# Player
const PLAYER_WALK_SPEED = 70
const PLAYER_TRANSFORM_SCALE = 0.9
const PLAYER_MAX_LIGHT_ENERGY = 0.8
const PLAYER_STAIR_SPEED_FACTOR = 0.6
const CRITICAL_ATTACK_DAMAGE_FACTOR = 1.5
const NORMAL_ATTACK_MIN_DAMAGE_FACTOR = 0.8
const NORMAL_ATTACK_MAX_DAMAGE_FACTOR = 1.2
const MAX_KNOCKBACK = 4
enum AttackDamageStates {
	NORMAL_ATTACK,
	CRITICAL_ATTACK
}
const AttackDamageStatesWeights = {
	AttackDamageStates.NORMAL_ATTACK: 0.9,
	AttackDamageStates.CRITICAL_ATTACK: 0.1,
}


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

# Minimap
const MINIMAP_GRASSLAND = "res://assets/ui/map_grassland.png"
const MINIMAP_CAMP = "res://assets/ui/map_camp.png"

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
const TRADE_INVENTORY_PATH = "res://scenes/inventory/TradeInventory.tscn"
const ITEM_DATA_PATH = "res://assets/data/ItemData.json"
const LOOT_DATA_PATH = "res://assets/data/LootData.json"
const CAMP_SCENE_PATH = "res://scenes/camp/Camp.tscn"
const GRASSLAND_SCENE_PATH = "res://scenes/grassland/Grassland.tscn"
const DEATH_SCREEN_PATH = "res://scenes/ui/DeathScreen.tscn"
const LOOT_PANEL_PATH = "res://scenes/looting/LootPanel.tscn"
const LOOT_DROP_PATH = "res://scenes/looting/LootDrop.tscn"
const TREASURE_PATH = "res://scenes/looting/Treasure.tscn"
const DIALOG_PATH = "res://scenes/npc/DialogueBox.tscn"
const FULL_INV_MSG = "res://scenes/inventory/Msg_Inv.tscn"

# inventory
const MAX_STACK_SIZE = 999
const TRADE_INV_SLOT = "res://scenes/inventory/TradeInventorySlot.tscn"
const INV_SLOT = "res://scenes/inventory/InventorySlot.tscn"
const TOOLTIP = "res://scenes/inventory/ToolTip.tscn"
const SPLIT_POPUP = "res://scenes/inventory/ItemSplitPopup.tscn"
const CHARACTER_INTERFACE_PATH = "res://scenes/inventory/CharacterInterface.tscn"
const MERCHANT = "res://assets/data/merchant_inv_data.json"
const INVENTORY_PATH = "res://assets/data/inv_data_file.json"

# Save file pathes
const SAVE_PATH = "user://"
const SAVE_SETTINGS_PATH = "user://settings.json"
const SAVE_CHARACTER_PATH = "user://character/"
const SAVE_INVENTORY_DATA_PATH = "user://data/"
const SAVE_GAME_PATH = "user://game/"
const SAVE_GAME_PATHFINDING_PATH = SAVE_GAME_PATH + "pathfinding/"

# Pathfinding variables
const POINTS_HORIZONTAL_PER_TILE = 3
const POINTS_VERTICAL_PER_TILE = 3
const POINT_SIZE_IN_PIXEL_PER_TILE = TILE_SIZE / POINTS_HORIZONTAL_PER_TILE

# Boss enemies pathes
const BossPathes = [
	"res://scenes/mobs/bosses/Boss_FungusBlue.tscn",
	"res://scenes/mobs/bosses/Boss_FungusBrown.tscn",
	"res://scenes/mobs/bosses/Boss_FungusPurple.tscn",
	"res://scenes/mobs/bosses/Boss_FungusRed.tscn",

	"res://scenes/mobs/bosses/Boss_GhostGreen.tscn",
	"res://scenes/mobs/bosses/Boss_GhostPurple.tscn",
	"res://scenes/mobs/bosses/Boss_GhostWhite.tscn",

	"res://scenes/mobs/bosses/Boss_OrbinautBlue.tscn",
	"res://scenes/mobs/bosses/Boss_OrbinautGreen.tscn",
	"res://scenes/mobs/bosses/Boss_OrbinautOrange.tscn",
	"res://scenes/mobs/bosses/Boss_OrbinautRed.tscn",

	"res://scenes/mobs/bosses/Boss_SkeletonBlue.tscn",
	"res://scenes/mobs/bosses/Boss_SkeletonRed.tscn",
	"res://scenes/mobs/bosses/Boss_SkeletonWhite.tscn",

	"res://scenes/mobs/bosses/Boss_SmallSlimeGreen.tscn",
	"res://scenes/mobs/bosses/Boss_SmallSlimeOrange.tscn",
	"res://scenes/mobs/bosses/Boss_SmallSlimePurple.tscn",
	"res://scenes/mobs/bosses/Boss_SmallSlimeRed.tscn",

	"res://scenes/mobs/bosses/Boss_ZombieBlue.tscn",
	"res://scenes/mobs/bosses/Boss_ZombieGreen.tscn",
	"res://scenes/mobs/bosses/Boss_ZombieGrey.tscn"
]

# Mobs
const PreloadedMobScenes = {
	"Butterfly": preload("res://scenes/mobs/Butterfly.tscn"),
	"Moth": preload("res://scenes/mobs/Moth.tscn"),
	
	"BatBlue": preload("res://scenes/mobs/BatBlue.tscn"),
	"BatPurple" : preload("res://scenes/mobs/BatPurple.tscn"),
	"BatRed" : preload("res://scenes/mobs/BatRed.tscn"),
	
	"FungusBlue" : preload("res://scenes/mobs/FungusBlue.tscn"),
	"FungusBrown" : preload("res://scenes/mobs/FungusBrown.tscn"),
	"FungusPurple" : preload("res://scenes/mobs/FungusPurple.tscn"),
	"FungusRed" : preload("res://scenes/mobs/FungusRed.tscn"),
	
	"GhostGreen" : preload("res://scenes/mobs/GhostGreen.tscn"),
	"GhostPurple" : preload("res://scenes/mobs/GhostPurple.tscn"),
	"GhostWhite" : preload("res://scenes/mobs/GhostWhite.tscn"),
	
	"OrbinautBlue" : preload("res://scenes/mobs/OrbinautBlue.tscn"),
	"OrbinautGreen" : preload("res://scenes/mobs/OrbinautGreen.tscn"),
	"OrbinautOrange" : preload("res://scenes/mobs/OrbinautOrange.tscn"),
	"OrbinautRed" : preload("res://scenes/mobs/OrbinautRed.tscn"),
	
	"RatGrey" : preload("res://scenes/mobs/RatGrey.tscn"),
	"RatRed" : preload("res://scenes/mobs/RatRed.tscn"),
	"RatWhite" : preload("res://scenes/mobs/RatWhite.tscn"),
	
	"SkeletonBlue" : preload("res://scenes/mobs/SkeletonBlue.tscn"),
	"SkeletonRed" : preload("res://scenes/mobs/SkeletonRed.tscn"),
	"SkeletonWhite" : preload("res://scenes/mobs/SkeletonWhite.tscn"),
	
	"SmallSlimeGreen" : preload("res://scenes/mobs/SmallSlimeGreen.tscn"),
	"SmallSlimeOrange" : preload("res://scenes/mobs/SmallSlimeOrange.tscn"),
	"SmallSlimePurple" : preload("res://scenes/mobs/SmallSlimePurple.tscn"),
	"SmallSlimeRed" : preload("res://scenes/mobs/SmallSlimeRed.tscn"),
	
	"SnakeGreen" : preload("res://scenes/mobs/SnakeGreen.tscn"),
	"SnakeGrey" : preload("res://scenes/mobs/SnakeGrey.tscn"),
	"SnakePurple" : preload("res://scenes/mobs/SnakePurple.tscn"),
	
	"ZombieBlue" : preload("res://scenes/mobs/ZombieBlue.tscn"),
	"ZombieGreen" : preload("res://scenes/mobs/ZombieGreen.tscn"),
	"ZombieGrey" : preload("res://scenes/mobs/ZombieGrey.tscn"),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
