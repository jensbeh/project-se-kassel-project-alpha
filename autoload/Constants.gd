extends Node

# Variables
var preload_stopped = false
var valid_window_sizes : Array = []

# ----------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------

# DEBUG
"""
#################
## GENERAL
#################
"""
const CAN_DEBUG = true # Default: false
const CAN_TOGGLE_DEBUGGING_WINDOW = true # Default: false

"""
#################
## AMBIENT MOBS
#################
"""
const SHOW_AMBIENT_MOB_COLLISION = false # Default: false
const SHOW_AMBIENT_MOB_PATHES = false # Default: false

"""
#################
## MOBS
#################
"""
const SHOW_MOB_COLLISION = false # Default: false
const SHOW_MOB_DETECTION_RADIUS = false # Default: false
const SHOW_MOB_PATHES = false # Default: false
const SHOW_MOB_HITBOX = false # Default: false
const SHOW_MOB_DAMAGE_AREA = false # Default: false

"""
#################
## BOSSES
#################
"""
const SHOW_BOSS_COLLISION = false # Default: false
const SHOW_BOSS_DETECTION_RADIUS = false # Default: false
const SHOW_BOSS_PATHES = false # Default: false
const SHOW_BOSS_HITBOX = false # Default: false
const SHOW_BOSS_DAMAGE_AREA = false # Default: false

"""
#################
## PLAYER
#################
"""
const IS_PLAYER_INVISIBLE = false # Default: false

const CAN_TOGGLE_PLAYER_INVINCIBLE = true # Default: false
var IS_PLAYER_INVINCIBLE = true # Default: false

const CAN_TOGGLE_PLAYER_INFINIT_STAMINA = true # Default: false
var HAS_PLAYER_INFINIT_STAMINA = true # Default: false


"""
#################
## PATHFINDING
#################
"""
const SHOW_PATHFINDING_POINTS = false # Default: false

"""
#################
## LOADED MAPS
#################
"""
const LOAD_GRASSLAND_MAP = true # Default: true
const LOAD_DUNGEONS_MAPS = true # Default: true

"""
#################
## TIME
#################
"""
const CAN_MODIFY_TIME = true # Default: false

# ----------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------


"""
#################
## GAME
#################
"""
const GAME_VERSION_NR = "1.0.1"
const GAME_BUILD_NR = 1
const DEFAULT_SOUND_VOLUME = -25
const DEFAULT_MUSIC_VOLUME = -15
const DEFAULT_WINDOW_MAXIMIZED = false
const DEFAULT_WINDOW_FULLSCREEN = true
var GAME_SETTINGS = {
	"language": "en",
	"sound": DEFAULT_SOUND_VOLUME,
	"music": DEFAULT_MUSIC_VOLUME,
	"window_size": var2str(WINDOW_SIZES.HD.value),
	"window_maximized": DEFAULT_WINDOW_MAXIMIZED,
	"window_fullscreen": DEFAULT_WINDOW_FULLSCREEN,
}
const WINDOW_SIZES = {
	"nHD": {
		"text": "640 x 360",
		"value": Vector2(640, 360),
	},
	"FWVGA": {
		"text": "854 x 480",
		"value": Vector2(854, 480),
	},
	"qHD": {
		"text": "960 x 540",
		"value": Vector2(960, 540),
	},
	"WSVGA": {
		"text": "1024 x 576",
		"value": Vector2(1024, 576),
	},
	"HD": {
		"text": "1280 x 720",
		"value": Vector2(1280, 720),
	},
	"FWXGA": {
		"text": "1366 x 768",
		"value": Vector2(1366, 768),
	},
	"HD+": {
		"text": "1600 x 900",
		"value": Vector2(1600, 900),
	},
	"FHD": {
		"text": "1920 x 1080",
		"value": Vector2(1920, 1080),
	}
}


"""
#################
## PLAYER
#################
"""
const NAME_LENGTH = 15
const MAX_LEVEL = 20
const FIRST_SPAWN_POSITION = Vector2(-60, 0)
const FIRST_VIEW_DIRECTION = Vector2(0, 1)
const FIRST_SPAWN_SCENE = "res://scenes/camp/buildings/House1.tscn"
const PLAYER_WALK_SPEED = 70
const PLAYER_TRANSFORM_SCALE = 0.9
const PLAYER_MAX_LIGHT_ENERGY = 0.8
const PLAYER_STAIR_SPEED_FACTOR = 0.6
const CRITICAL_ATTACK_DAMAGE_FACTOR = 1.5
const NORMAL_ATTACK_MIN_DAMAGE_FACTOR = 0.8
const NORMAL_ATTACK_MAX_DAMAGE_FACTOR = 1.2
const MIN_KNOCKBACK_VELOCITY_FACTOR_TO_PLAYER = 25
const MAX_KNOCKBACK_VELOCITY_FACTOR_TO_PLAYER = 100
const MAX_KNOCKBACK = 4
const WEAPON_STAMINA_USE = 5 # * Weapon weight per hit
const STAMINA_SPRINT = 15 # Points per second
const STAMINA_RECOVER = 12 # Points per second
const RESCUE_PAY_GOLD_FACTOR = 0.1 # 10%
const MIN_LEVEL_ITEM_LOSE = 3
const MIN_LOST_FACTOR = 10
enum AttackDamageStates {
	NORMAL_ATTACK,
	CRITICAL_ATTACK
}
const AttackDamageStatesProbabilityWeights = {
	AttackDamageStates.NORMAL_ATTACK: 0.9,
	AttackDamageStates.CRITICAL_ATTACK: 0.1,
}


"""
#################
## INNVENTORY
#################
"""
const MAX_STACK_SIZE = 5
const HEALTH_COOLDOWN = 20
const STAMINA_POTION_COOLDOWN = 15
const RESELL_FACTOR = 0.5 # 50% of its cost (Factor price x2 -> Keys, Rescourcen, Jewel)


"""
#################
## LOOTING
#################
"""
const LOOTING_TIME = 60 # In seconds
const LOOT_CHANCE = 0.7 # Means 70% Chance


"""
#################
## DAY_NIGHT COLORS
#################
"""
const DAY_COLOR = Color("ffffff")
const SUNSET_COLOR = Color("ff8f53")
const NIGHT_COLOR = Color("212121")
const SUNRISE_COLOR = Color("ff8f53")
const DUNGEON_COLOR = Color("000000")


"""
#################
## MAPS
#################
"""
const TILE_SIZE = 16
const PSEUDO_OBSTACLE_TILE_ID = 22
const PSEUDO_OBSTACLE_TILE_ID_DUNGEONS = 39
const INVALID_TILE_ID = -1

"""
#################
## CHUNKS
#################
"""
const CHUNK_SIZE_TILES = 10 # In tiles -> if changing need reimport of maps!
const chunk_size_pixel = CHUNK_SIZE_TILES * TILE_SIZE # In pixel
const RENDER_DISTANCE = 3 # Loaded chunks each direction except the one where the player stands -> min 3 !!!

"""
#################
## MOB_SPAWNER
#################
"""
const MAX_AMBIENT_MOBS_GRASSLAND = 50

"""
#################
## PATHFINDING
#################
"""
const POINTS_HORIZONTAL_PER_TILE = 3
const POINTS_VERTICAL_PER_TILE = 3
const POINT_SIZE_IN_PIXEL_PER_TILE = ceil(float(TILE_SIZE) / (POINTS_HORIZONTAL_PER_TILE - 1))
const ASTAR_MAP_NAMES_PATHES = {
	"map_dungeon1_lvl1": "res://scenes/dungeons/dungeon1/Dungeon1-lvl1.tscn",
	"map_dungeon1_lvl2": "res://scenes/dungeons/dungeon1/Dungeon1-lvl2.tscn",
	"map_dungeon1_lvl3": "res://scenes/dungeons/dungeon1/Dungeon1-lvl3.tscn",
	"map_dungeon2_lvl1": "res://scenes/dungeons/dungeon2/Dungeon2-lvl1.tscn",
	"map_dungeon2_lvl2": "res://scenes/dungeons/dungeon2/Dungeon2-lvl2.tscn",
	"map_dungeon2_lvl3": "res://scenes/dungeons/dungeon2/Dungeon2-lvl3.tscn",
	"map_dungeon2_lvl4": "res://scenes/dungeons/dungeon2/Dungeon2-lvl4.tscn",
	"map_dungeon3_lvl1": "res://scenes/dungeons/dungeon3/Dungeon3-lvl1.tscn",
	"map_dungeon3_lvl2": "res://scenes/dungeons/dungeon3/Dungeon3-lvl2.tscn",
	"map_dungeon3_lvl3": "res://scenes/dungeons/dungeon3/Dungeon3-lvl3.tscn",
	"map_dungeon3_lvl4": "res://scenes/dungeons/dungeon3/Dungeon3-lvl4.tscn",
	"map_grassland": "res://scenes/grassland/Grassland.tscn",
}

"""
#################
## SCENE
#################
"""
# Transition type of scene
enum TransitionType {
	GAME_SCENE,
	MENU_SCENE
}
# Scene info
enum SceneType {
	MENU,
	CAMP,
	HOUSE,
	GRASSLAND,
	DUNGEON
}


"""
#################
## NPCs
#################
"""
# NPCs walk speed
const NPC_NORMAL_SPEED = 30
const NPC_STAIRS_SPEED = NPC_NORMAL_SPEED*0.6


"""
#################
## MOBS
#################
"""
const MOB_RESPAWN_TIMER = 180.0 # in sec
const MOB_RESPAWN_TIMER_BOSS_ROOM = 30.0 # in sec
# Spawn times
enum SpawnTime {
	ONLY_DAY,
	ONLY_NIGHT,
	ALWAYS
}

# Mobs settings
const MOB_SPEED_FACTOR = 2.2
const MOB_PRE_ATTACK_SPEED_FACTOR = 1.2
const MOB_DIFFICULTY_FACTOR = 0.5 # Normal = 0.5
const MOB_HEALTH_FACTOR = 0.75 # Normal = 0.75
const MobsSettings = {
	# General mob settings
	"GENERAL": {
		"AttackRadius" : 32,
		"MobSpeedFactor" : 2.2,
		"DirectAttackStyleProbability" : 0.35, # 35% chance to attack directly
		"MinKnockbackVelocityFactorToMob" : 50,
		"MaxKnockbackVelocityFactorToMob" : 150
	},
	
	# Bat settings
	"BAT": {
		"Health" : 75 * MOB_HEALTH_FACTOR,
		"AttackDamage" : 20 * MOB_DIFFICULTY_FACTOR,
		"Knockback" : 1,
		"Weight" : 10,
		"Experience" : 8 * MOB_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ONLY_NIGHT,
		"HuntingSpeed" : 50 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 25 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 50 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Fungus settings
	"FUNGUS": {
		"Health" : 110 * MOB_HEALTH_FACTOR,
		"AttackDamage" : 25 * MOB_DIFFICULTY_FACTOR,
		"Knockback" : 2,
		"Weight" : 40,
		"Experience" : 14 * MOB_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 12 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 25 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 12,
		"MaxSearchingTime" : 18,
	},
	
	# Ghost settings
	"GHOST": {
		"Health" : 90 * MOB_HEALTH_FACTOR,
		"AttackDamage" : 20 * MOB_DIFFICULTY_FACTOR,
		"Knockback" : 1,
		"Weight" : 5,
		"Experience" : 9 * MOB_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 35 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 12 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 35 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Orbinaut settings
	"ORBINAUT": {
		"Health" : 85 * MOB_HEALTH_FACTOR,
		"AttackDamage" : 25 * MOB_DIFFICULTY_FACTOR,
		"Knockback" : 4,
		"Weight" : 35,
		"Experience" : 12 * MOB_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ONLY_NIGHT,
		"HuntingSpeed" : 45 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 8 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 45 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Rat settings
	"RAT": {
		"Health" : 80 * MOB_HEALTH_FACTOR,
		"AttackDamage" : 15 * MOB_DIFFICULTY_FACTOR,
		"Knockback" : 1,
		"Weight" : 10,
		"Experience" : 8 * MOB_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ONLY_NIGHT,
		"HuntingSpeed" : 35 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 20 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 35 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Skeleton settings
	"SKELETON": {
		"Health" : 120 * MOB_HEALTH_FACTOR,
		"AttackDamage" : 30 * MOB_DIFFICULTY_FACTOR,
		"Knockback" : 3,
		"Weight" : 40,
		"Experience" : 15 * MOB_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 20 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 25 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Small_Slime settings
	"SMALL_SLIME": {
		"Health" : 100 * MOB_HEALTH_FACTOR,
		"AttackDamage" : 20 * MOB_DIFFICULTY_FACTOR,
		"Knockback" : 2,
		"Weight" : 30,
		"Experience" : 10 * MOB_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ONLY_DAY,
		"HuntingSpeed" : 25 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 12 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 25 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Snake settings
	"SNAKE": {
		"Health" : 80 * MOB_HEALTH_FACTOR,
		"AttackDamage" : 25 * MOB_DIFFICULTY_FACTOR,
		"Knockback" : 1,
		"Weight" : 10,
		"Experience" : 8 * MOB_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ONLY_DAY,
		"HuntingSpeed" : 35 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 20 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 35 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Zombie settings
	"ZOMBIE": {
		"Health" : 130 * MOB_HEALTH_FACTOR,
		"AttackDamage" : 35 * MOB_DIFFICULTY_FACTOR,
		"Knockback" : 3,
		"Weight" : 50,
		"Experience" : 16 * MOB_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 20 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 10 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 20 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
}



"""
#################
## BOSSES
#################
"""
# Boss settings
const BOSS_SPEED_FACTOR = 3.5
const BOSS_PRE_ATTACK_SPEED_FACTOR = 1.5
const BOSS_DIFFICULTY_FACTOR = 1.0 # Normal = 1.0
const BOSS_HEALTH_FACTOR = 1.0 * BOSS_DIFFICULTY_FACTOR # Normal = 1.0
const BossesSettings = {
	# General boss settings
	"GENERAL": {
		"DetectionRadiusInGrassland" : 60,
		"DetectionRadiusInDungeon" : 100,
		"AttackRadiusInGrassland" : 50.0,
		"AttackRadiusInDungeon" : 50.0,
		"DirectAttackStyleProbability" : 0.35, # 35% chance to attack directly
		"MinKnockbackVelocityFactorToBoss" : 50,
		"MaxKnockbackVelocityFactorToBoss" : 100
	},
	
	# Boss_Fungus settings
	"BOSS_FUNGUS": {
		"Health" : 750 * BOSS_HEALTH_FACTOR,
		"AttackDamage" : 40 * BOSS_DIFFICULTY_FACTOR,
		"Knockback" : 4,
		"Weight" : 100,
		"Experience" : 50 * BOSS_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 12 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 25 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Boss_Ghost settings
	"BOSS_GHOST": {
		"Health" : 750 * BOSS_HEALTH_FACTOR,
		"AttackDamage" : 40 * BOSS_DIFFICULTY_FACTOR,
		"Knockback" : 4,
		"Weight" : 50,
		"Experience" : 50 * BOSS_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 35 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 12 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 35 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Boss_Orbinaut settings
	"BOSS_ORBINAUT": {
		"Health" : 750 * BOSS_HEALTH_FACTOR,
		"AttackDamage" : 40 * BOSS_DIFFICULTY_FACTOR,
		"Knockback" : 4,
		"Weight" : 70,
		"Experience" : 50 * BOSS_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 45 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 8 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 45 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Boss_Skeleton settings
	"BOSS_SKELETON": {
		"Health" : 750 * BOSS_HEALTH_FACTOR,
		"AttackDamage" : 40 * BOSS_DIFFICULTY_FACTOR,
		"Knockback" : 4,
		"Weight" : 100,
		"Experience" : 50 * BOSS_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 20 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 25 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Boss_Small_Slime settings
	"BOSS_SMALL_SLIME": {
		"Health" : 750 * BOSS_HEALTH_FACTOR,
		"AttackDamage" : 40 * BOSS_DIFFICULTY_FACTOR,
		"Knockback" : 4,
		"Weight" : 50,
		"Experience" : 50 * BOSS_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 12 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 25 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Boss_Zombie settings
	"BOSS_ZOMBIE": {
		"Health" : 750 * BOSS_HEALTH_FACTOR,
		"AttackDamage" : 40 * BOSS_DIFFICULTY_FACTOR,
		"Knockback" : 4,
		"Weight" : 80,
		"Experience" : 50 * BOSS_DIFFICULTY_FACTOR,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 20 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 10 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 20 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
}


"""
#################
## PATHES
#################
"""
# Folder
const MENU_FOLDER = "res://scenes/menu/"
const CAMP_FOLDER = "res://scenes/camp/"
const CAMP_BUILDING_FOLDER = "res://scenes/camp/buildings/"
const GRASSLAND_FOLDER = "res://scenes/grassland/"
const GRASSLAND_BUILDING_FOLDER = "res://scenes/grassland/buildings/"
const DUNGEONS_FOLDER = "res://scenes/dungeons/"

# Scenes
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
const GOLDEN_KEY_PATH = "res://scenes/items/golden_key.tscn"
const TRADE_INV_SLOT = "res://scenes/inventory/TradeInventorySlot.tscn"
const INV_SLOT = "res://scenes/inventory/InventorySlot.tscn"
const TOOLTIP = "res://scenes/inventory/ToolTip.tscn"
const SPLIT_POPUP = "res://scenes/inventory/ItemSplitPopup.tscn"
const CHARACTER_INTERFACE_PATH = "res://scenes/inventory/CharacterInterface.tscn"
const CREDIT_SCREEN_PATH = "res://scenes/credits/CreditScreen.tscn"
const STORY_SCENE_PATH = "res://scenes/story/IntroStory.tscn"
const QUEST_SCENE_PATH = "res://scenes/story/quest/QuestList.tscn"
const QUEST_SLOT_PATH = "res://scenes/story/quest/QuestSlot.tscn"

# Save file pathes
const APP_DATA_FOLDER_PATH = "user://"
const DEFAULT_PLAYER_INV_PATH = "res://assets/data/inv_data_file.json"
const MERCHANTS_PATH = "res://assets/data/merchant_inv_data.json"
const SAVE_SETTINGS_PATH = "user://game/settings.json"
const SAVE_CHARACTER_PATH = "user://character/"
const SAVE_GAME_PATH = "user://game/"
const VERSION_PATH = SAVE_GAME_PATH + "version.sav"
const SAVE_GAME_PATHFINDING_PATH = "res://assets/pathfinding/"


"""
#################
## PRELOADED MENUS & MAPS
#################
"""
var PreloadedMenusAndMaps = {}

"""
#################
## PRELOADED SCENES
#################
"""
# Preloaded mob scenes
var PreloadedMobScenes = {}

# Preloaded boss scenes
var PreloadBossScene = []

# Preloaded scenes
var PreloadedScenes = {}


"""
#################
## PRELOADED MUSIC
#################
"""
# Cant load these in preload method because music is needed direcly
const PreloadedMusic = {
	"Menu_Music" : preload("res://assets/sounds/awesomeness.wav"),
	"House":  preload("res://assets/sounds/menuLoops_microtonalSynthpop(22EDO).ogg"),
	"Camp" : preload("res://assets/sounds/little town - orchestral.ogg"),
	"House_Grassland" : preload("res://assets/sounds/forest.mp3"),
	"Night" : preload("res://assets/sounds/night-crickets-ambience-on-rural-property.mp3"),
	"Grassland" : preload("res://assets/sounds/Outdoor_Ambiance.mp3"),
	"Dungeon" : preload("res://assets/sounds/Ambience_Cave_00.mp3"),
	"Tavern" : preload("res://assets/sounds/Rezoner-Pirates-Theme.mp3"),
	"Hostel" : preload("res://assets/sounds/Ove Melaa - Times.mp3"),
	"Boss_Fight1" : preload("res://assets/sounds/battleThemeA.mp3"),
	"Boss_Fight2" : preload("res://assets/sounds/battleThemeB.mp3"),
	"Credits" : preload("res://assets/sounds/Farewell.mp3"),
}

"""
#################
## PRELOADED SOUNDS
#################
"""
var PreloadedSounds = {}


"""
#################
## PRELOADED TEXTURES
#################
"""
var PreloadedTextures = {}


"""
#################
## PRELOADED PLAYER SPRITES
#################
"""
var PreloadedPlayerSprites = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	#-------------------------------------------------------------
	
	# Section only for debugging
	# Check flags
	printerr("")
	printerr("######################################")
	printerr("## CHECKING FOR DEBUGGING FLAGS...")
	printerr("##")
	# GAME
	# Can modify game
	if Constants.CAN_DEBUG:
		printerr("## -> Game can be manipulated")
	if Constants.CAN_TOGGLE_DEBUGGING_WINDOW:
		printerr("## -> Debugging window can be toggled")
	
	# MOBS
	if Constants.SHOW_AMBIENT_MOB_COLLISION:
		printerr("## -> Collisions shown of ambient mobs")
	if Constants.SHOW_AMBIENT_MOB_PATHES:
		printerr("## -> Pathes shown of ambient mobs")
	if Constants.SHOW_MOB_COLLISION:
		printerr("## -> Collisions shown of mobs")
	if Constants.SHOW_MOB_DETECTION_RADIUS:
		printerr("## -> Detection radius shown of mobs")
	if Constants.SHOW_MOB_PATHES:
		printerr("## -> Pathes shown of mobs")
	if Constants.SHOW_MOB_HITBOX:
		printerr("## -> Hitbox shown of mobs")
	if Constants.SHOW_MOB_DAMAGE_AREA:
		printerr("## -> Damage area shown of mobs")
	
	# BOSSES
	if Constants.SHOW_BOSS_COLLISION:
		printerr("## -> Collisions shown of bosses")
	if Constants.SHOW_BOSS_DETECTION_RADIUS:
		printerr("## -> Detection radius shown of bosses")
	if Constants.SHOW_BOSS_PATHES:
		printerr("## -> Pathes shown of bosses")
	if Constants.SHOW_BOSS_HITBOX:
		printerr("## -> Hitbox shown of bosses")
	if Constants.SHOW_BOSS_DAMAGE_AREA:
		printerr("## -> Damage area shown of bosses")
	
	# PLAYER
	# Invisibility
	if Constants.IS_PLAYER_INVISIBLE:
		printerr("## -> Player is invisible")
	# Invincibility
	if Constants.IS_PLAYER_INVINCIBLE:
		printerr("## -> Player is invincible")
	if Constants.CAN_TOGGLE_PLAYER_INVINCIBLE:
		printerr("## -> Can toggle player invincible")
	# Infinit stamina
	if Constants.HAS_PLAYER_INFINIT_STAMINA:
		printerr("## -> Player has infinit stamina")
	if Constants.CAN_TOGGLE_PLAYER_INFINIT_STAMINA:
		printerr("## -> Can toggle player infinit stamina")
	
	# MAPS
	if not Constants.LOAD_GRASSLAND_MAP:
		printerr("## -> Pathfinding of grassland not loading")
	if not Constants.LOAD_DUNGEONS_MAPS:
		printerr("## -> Pathfinding of dungeons not loading")
	
	# TIME
	# Can modify time
	if Constants.CAN_MODIFY_TIME:
		printerr("## -> Time can be manipulated")
	
	printerr("##")
	printerr("## CHECKED!")
	printerr("######################################")
	printerr("")
	#-------------------------------------------------------------


func preload_variables():
	print("CONSTANTS: Preloading...")
	
	"""
	#################
	## PRELOADED MENUS & MAPS
	#################
	"""
	PreloadedMenusAndMaps = {
		# Menu
		"res://scenes/menu/MainMenuScreen.tscn": load_ressource("res://scenes/menu/MainMenuScreen.tscn"),
		"res://scenes/menu/character_screens/CharacterScreen.tscn": load_ressource("res://scenes/menu/character_screens/CharacterScreen.tscn"),
		"res://scenes/menu/character_screens/CreateCharacter.tscn": load_ressource("res://scenes/menu/character_screens/CreateCharacter.tscn"),
		"res://scenes/story/IntroStory.tscn": load_ressource("res://scenes/story/IntroStory.tscn"),
		"res://scenes/credits/CreditScreen.tscn": load_ressource("res://scenes/credits/CreditScreen.tscn"),
		# Camp
		"res://scenes/camp/Camp.tscn": load_ressource("res://scenes/camp/Camp.tscn"),
		"res://scenes/camp/buildings/Hostel.tscn": load_ressource("res://scenes/camp/buildings/Hostel.tscn"),
		"res://scenes/camp/buildings/Hostel-lvl2.tscn": load_ressource("res://scenes/camp/buildings/Hostel-lvl2.tscn"),
		"res://scenes/camp/buildings/House1.tscn": load_ressource("res://scenes/camp/buildings/House1.tscn"),
		"res://scenes/camp/buildings/House2.tscn": load_ressource("res://scenes/camp/buildings/House2.tscn"),
		"res://scenes/camp/buildings/House4.tscn": load_ressource("res://scenes/camp/buildings/House4.tscn"),
		"res://scenes/camp/buildings/House5.tscn": load_ressource("res://scenes/camp/buildings/House5.tscn"),
		"res://scenes/camp/buildings/Tavern.tscn": load_ressource("res://scenes/camp/buildings/Tavern.tscn"),
		"res://scenes/camp/buildings/Tavern-lvl2.tscn": load_ressource("res://scenes/camp/buildings/Tavern-lvl2.tscn"),
		# Grassland
		"res://scenes/grassland/Grassland.tscn": load_ressource("res://scenes/grassland/Grassland.tscn"),
		"res://scenes/grassland/buildings/House1.tscn": load_ressource("res://scenes/grassland/buildings/House1.tscn"),
		"res://scenes/grassland/buildings/House1-basement.tscn": load_ressource("res://scenes/grassland/buildings/House1-basement.tscn"),
		# Dungeon1
		"res://scenes/dungeons/dungeon1/Dungeon1-lvl1.tscn": load_ressource("res://scenes/dungeons/dungeon1/Dungeon1-lvl1.tscn"),
		"res://scenes/dungeons/dungeon1/Dungeon1-lvl2.tscn": load_ressource("res://scenes/dungeons/dungeon1/Dungeon1-lvl2.tscn"),
		"res://scenes/dungeons/dungeon1/Dungeon1-lvl3.tscn": load_ressource("res://scenes/dungeons/dungeon1/Dungeon1-lvl3.tscn"),
		# Dungeon2
		"res://scenes/dungeons/dungeon2/Dungeon2-lvl1.tscn": load_ressource("res://scenes/dungeons/dungeon2/Dungeon2-lvl1.tscn"),
		"res://scenes/dungeons/dungeon2/Dungeon2-lvl2.tscn": load_ressource("res://scenes/dungeons/dungeon2/Dungeon2-lvl2.tscn"),
		"res://scenes/dungeons/dungeon2/Dungeon2-lvl3.tscn": load_ressource("res://scenes/dungeons/dungeon2/Dungeon2-lvl3.tscn"),
		"res://scenes/dungeons/dungeon2/Dungeon2-lvl4.tscn": load_ressource("res://scenes/dungeons/dungeon2/Dungeon2-lvl4.tscn"),
		# Dungeon3
		"res://scenes/dungeons/dungeon3/Dungeon3-lvl1.tscn": load_ressource("res://scenes/dungeons/dungeon3/Dungeon3-lvl1.tscn"),
		"res://scenes/dungeons/dungeon3/Dungeon3-lvl2.tscn": load_ressource("res://scenes/dungeons/dungeon3/Dungeon3-lvl2.tscn"),
		"res://scenes/dungeons/dungeon3/Dungeon3-lvl3.tscn": load_ressource("res://scenes/dungeons/dungeon3/Dungeon3-lvl3.tscn"),
		"res://scenes/dungeons/dungeon3/Dungeon3-lvl4.tscn": load_ressource("res://scenes/dungeons/dungeon3/Dungeon3-lvl4.tscn"),
	}
	
	
	"""
	#################
	## PRELOADED SCENES
	#################
	"""
	# Preloaded mob scenes
	PreloadedMobScenes = {
		"Butterfly": load_ressource("res://scenes/mobs/Butterfly.tscn"),
		"Moth": load_ressource("res://scenes/mobs/Moth.tscn"),
		
		"BatBlue": load_ressource("res://scenes/mobs/BatBlue.tscn"),
		"BatPurple" : load_ressource("res://scenes/mobs/BatPurple.tscn"),
		"BatRed" : load_ressource("res://scenes/mobs/BatRed.tscn"),
		
		"FungusBlue" : load_ressource("res://scenes/mobs/FungusBlue.tscn"),
		"FungusBrown" : load_ressource("res://scenes/mobs/FungusBrown.tscn"),
		"FungusPurple" : load_ressource("res://scenes/mobs/FungusPurple.tscn"),
		"FungusRed" : load_ressource("res://scenes/mobs/FungusRed.tscn"),
		
		"GhostGreen" : load_ressource("res://scenes/mobs/GhostGreen.tscn"),
		"GhostPurple" : load_ressource("res://scenes/mobs/GhostPurple.tscn"),
		"GhostWhite" : load_ressource("res://scenes/mobs/GhostWhite.tscn"),
		
		"OrbinautBlue" : load_ressource("res://scenes/mobs/OrbinautBlue.tscn"),
		"OrbinautGreen" : load_ressource("res://scenes/mobs/OrbinautGreen.tscn"),
		"OrbinautOrange" : load_ressource("res://scenes/mobs/OrbinautOrange.tscn"),
		"OrbinautRed" : load_ressource("res://scenes/mobs/OrbinautRed.tscn"),
		
		"RatGrey" : load_ressource("res://scenes/mobs/RatGrey.tscn"),
		"RatRed" : load_ressource("res://scenes/mobs/RatRed.tscn"),
		"RatWhite" : load_ressource("res://scenes/mobs/RatWhite.tscn"),
		
		"SkeletonBlue" : load_ressource("res://scenes/mobs/SkeletonBlue.tscn"),
		"SkeletonRed" : load_ressource("res://scenes/mobs/SkeletonRed.tscn"),
		"SkeletonWhite" : load_ressource("res://scenes/mobs/SkeletonWhite.tscn"),
		
		"SmallSlimeGreen" : load_ressource("res://scenes/mobs/SmallSlimeGreen.tscn"),
		"SmallSlimeOrange" : load_ressource("res://scenes/mobs/SmallSlimeOrange.tscn"),
		"SmallSlimePurple" : load_ressource("res://scenes/mobs/SmallSlimePurple.tscn"),
		"SmallSlimeRed" : load_ressource("res://scenes/mobs/SmallSlimeRed.tscn"),
		
		"SnakeGreen" : load_ressource("res://scenes/mobs/SnakeGreen.tscn"),
		"SnakeGrey" : load_ressource("res://scenes/mobs/SnakeGrey.tscn"),
		"SnakePurple" : load_ressource("res://scenes/mobs/SnakePurple.tscn"),
		
		"ZombieBlue" : load_ressource("res://scenes/mobs/ZombieBlue.tscn"),
		"ZombieGreen" : load_ressource("res://scenes/mobs/ZombieGreen.tscn"),
		"ZombieGrey" : load_ressource("res://scenes/mobs/ZombieGrey.tscn"),
	}
	
	# Preloaded boss scenes
	PreloadBossScene = [
		load_ressource("res://scenes/mobs/bosses/Boss_FungusBlue.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_FungusBrown.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_FungusPurple.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_FungusRed.tscn"),
		
		load_ressource("res://scenes/mobs/bosses/Boss_GhostGreen.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_GhostPurple.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_GhostWhite.tscn"),
		
		load_ressource("res://scenes/mobs/bosses/Boss_OrbinautBlue.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_OrbinautGreen.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_OrbinautOrange.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_OrbinautRed.tscn"),
		
		load_ressource("res://scenes/mobs/bosses/Boss_SkeletonBlue.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_SkeletonRed.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_SkeletonWhite.tscn"),
		
		load_ressource("res://scenes/mobs/bosses/Boss_SmallSlimeGreen.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_SmallSlimeOrange.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_SmallSlimePurple.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_SmallSlimeRed.tscn"),
		
		load_ressource("res://scenes/mobs/bosses/Boss_ZombieBlue.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_ZombieGreen.tscn"),
		load_ressource("res://scenes/mobs/bosses/Boss_ZombieGrey.tscn")
	]
	
	# Preloaded scenes
	PreloadedScenes = {
		"GoldenKeyScene": load_ressource(GOLDEN_KEY_PATH),
		"CharacterScreenContainer": load_ressource(CHARACTER_SCREEN_CONTAINER_SCRIPT_PATH),
		"GameMenuScene" : load_ressource(GAME_MENU_PATH),
		"SettingScene" : load_ressource(SETTINGS_PATH),
		"TradeInventoryScene" : load_ressource(TRADE_INVENTORY_PATH),
		"DeathScreenScene" : load_ressource(DEATH_SCREEN_PATH),
		"LootPanelScene" : load_ressource(LOOT_PANEL_PATH),
		"LootDropScene" : load_ressource(LOOT_DROP_PATH),
		"TreasureScene" : load_ressource(TREASURE_PATH),
		"DialogScene" : load_ressource(DIALOG_PATH),
		"FullInvMsgScene" : load_ressource(FULL_INV_MSG),
		"TradeInvSlotScene" : load_ressource(TRADE_INV_SLOT),
		"InvSlotScene" : load_ressource(INV_SLOT),
		"TooltipScene" : load_ressource(TOOLTIP),
		"SplitPopupScene" : load_ressource(SPLIT_POPUP),
		"CharacterInterfaceScene" : load_ressource(CHARACTER_INTERFACE_PATH),
		"QuestScene" : load_ressource(QUEST_SCENE_PATH),
		"QuestSlot" : load_ressource(QUEST_SLOT_PATH),
	}
	
	
	"""
	#################
	## PRELOADED SOUNDS
	#################
	"""
	PreloadedSounds = {
		"Switch" : load_ressource("res://assets/sounds/switch6.wav"),
		"Click" : load_ressource("res://assets/sounds/click3.wav"),
		"Choose" : load_ressource("res://assets/sounds/rollover2.wav"),
		"Select" : load_ressource("res://assets/sounds/Menu_Select_00.mp3"),
		"Delete" : load_ressource("res://assets/sounds/UI_027.wav"),
		"Levelup" : load_ressource("res://assets/sounds/snare.wav"),
		"OpenUI" : load_ressource("res://assets/sounds/Inventory_Open_00.mp3"),
		"OpenUI2" : load_ressource("res://assets/sounds/Inventory_Open_01.mp3"),
		"Sucsess" : load_ressource ("res://assets/sounds/Jingle_Achievement_00.mp3"),
		"Lose" : load_ressource("res://assets/sounds/Jingle_Lose_00.mp3"),
		"Win" : load_ressource("res://assets/sounds/Jingle_Win_00.mp3"),
		"Collect" : load_ressource("res://assets/sounds/Pickup_Gold_00.mp3"),
		"Collect2" : load_ressource("res://assets/sounds/chainmail1.wav"),
		"open_door" : load_ressource("res://assets/sounds/doorOpen_2.ogg"),
		"locked" : load_ressource("res://assets/sounds/lockeddoor.wav"),
		"Potion" : load_ressource("res://assets/sounds/bubble.wav"),
		"Potion1" : load_ressource("res://assets/sounds/bubble2.wav"),
		"Dialog" : load_ressource("res://assets/sounds/Pen_v4_wav.wav"),
		"Equip" : load_ressource("res://assets/sounds/SetSomething.ogg"),
		"open_close" : load_ressource("res://assets/sounds/interface2.wav"),
		"Steps_Stairs" : load_ressource("res://assets/sounds/stepstone_7.wav"),
		"Steps_Grassland" : load_ressource("res://assets/sounds/grass_footsteps.wav"),
		"Steps_Dungeon" : load_ressource("res://assets/sounds/hard-footstep.mp3"),
		"Steps_Camp" : load_ressource("res://assets/sounds/stepdirt.mp3"),
		"Steps_House" : load_ressource("res://assets/sounds/step.mp3"),
		"Breath" : load_ressource("res://assets/sounds/breath-male.mp3"),
		"Hurt" : load_ressource("res://assets/sounds/hit34.mp3.mp3"),
		"Attack" : load_ressource("res://assets/sounds/swing.wav"),
		"Drop" : load_ressource("res://assets/sounds/plugpull.wav"),
		"Eat" : load_ressource("res://assets/sounds/beads.wav"),
	}
	
	
	"""
	#################
	## PRELOADED TEXTURES
	#################
	"""
	PreloadedTextures = {
		# Weapons
		"10001" : load_ressource("res://assets/player/weapons/wooden_sword_10001.png"),
		"10002" : load_ressource("res://assets/player/weapons/iron_sword_10002.png"),
		"10003" : load_ressource("res://assets/player/weapons/balanced_sword_10003.png"),
		"10004" : load_ressource("res://assets/player/weapons/large_dagger_10004.png"),
		"10005" : load_ressource("res://assets/player/weapons/greate_sword_10005.png"),
		"10006" : load_ressource("res://assets/player/weapons/epic_sword_10006.png"),
		"10007" : load_ressource("res://assets/player/weapons/legendary_sword_10007.png"),
		"10008" : load_ressource("res://assets/player/weapons/normal_axe_10008.png"),
		"10009" : load_ressource("res://assets/player/weapons/greate_axe_10009.png"),
	}
	
	
	"""
	#################
	## PRELOADED PLAYER SPRITES
	#################
	"""
	PreloadedPlayerSprites = {
		"BODY_SPRITESHEET" : {
			0: load_ressource("res://assets/player/characters/char1.png"),
			1: load_ressource("res://assets/player/characters/char2.png"),
			2: load_ressource("res://assets/player/characters/char3.png"),
			3: load_ressource("res://assets/player/characters/char4.png"),
			4: load_ressource("res://assets/player/characters/char5.png"),
			5: load_ressource("res://assets/player/characters/char6.png"),
			6: load_ressource("res://assets/player/characters/char7.png"),
			7: load_ressource("res://assets/player/characters/char8.png"),
		},
		
		"CLOTHES_SPRITESHEET" : {
			0: load_ressource("res://assets/player/clothes/basic.png"),
			1: load_ressource("res://assets/player/clothes/dress .png"),
			2: load_ressource("res://assets/player/clothes/floral.png"),
			3: load_ressource("res://assets/player/clothes/overalls.png"),
			4: load_ressource("res://assets/player/clothes/sailor.png"),
			5: load_ressource("res://assets/player/clothes/sailor_bow.png"),
			6: load_ressource("res://assets/player/clothes/skull.png"),
			7: load_ressource("res://assets/player/clothes/spaghetti.png"),
			8: load_ressource("res://assets/player/clothes/sporty.png"),
			9: load_ressource("res://assets/player/clothes/stripe.png"),
			10: load_ressource("res://assets/player/clothes/suit.png"),
		},
		
		"CLOTHES1_SPRITESHEET" : {
			0: load_ressource("res://assets/player/clothes/spooky .png"),
			1: load_ressource("res://assets/player/clothes/witch.png"),
		},
		
		"CLOTHES2_SPRITESHEET" : {
			0: load_ressource("res://assets/player/clothes/pumpkin.png"),
			1: load_ressource("res://assets/player/clothes/clown.png"),
		},
		
		"PANTS_SPRITESHEET" : {
			0: load_ressource("res://assets/player/clothes/skirt.png"),
			1: load_ressource("res://assets/player/clothes/pants_suit.png"),
			2: load_ressource("res://assets/player/clothes/pants.png"),
		},
		
		"SHOES_SPRITESHEET" : {
			0: load_ressource("res://assets/player/clothes/shoes.png"),
		},
		
		"BEARD_SPRITESHEET" : {
			0: load_ressource("res://assets/player/acc/beard.png"),
		},
		
		"EARRING_SPRITESHEET" : {
			0: load_ressource("res://assets/player/acc/earring_emerald.png"),
			1: load_ressource("res://assets/player/acc/earring_emerald_silver.png"),
			2: load_ressource("res://assets/player/acc/earring_red.png"),
			3: load_ressource("res://assets/player/acc/earring_red_silver.png"),
		},
		
		"GLASSES_SPRITESHEET" : {
			0: load_ressource("res://assets/player/acc/glasses.png"),
			1: load_ressource("res://assets/player/acc/glasses_sun.png"),
		},
		
		"HAT_SPRITESHEET" : {
			0: load_ressource("res://assets/player/acc/hat_cowboy.png"),
			1: load_ressource("res://assets/player/acc/hat_lucky.png"),
			2: load_ressource("res://assets/player/acc/hat_pumpkin.png"),
			3: load_ressource("res://assets/player/acc/hat_pumpkin_purple.png"),
			4: load_ressource("res://assets/player/acc/hat_witch.png"),
		},
		
		"MASK_SPRITESHEET" : {
			0: load_ressource("res://assets/player/acc/mask_clown_blue.png"),
			1: load_ressource("res://assets/player/acc/mask_clown_red.png"),
			2: load_ressource("res://assets/player/acc/mask_spooky.png"),
		},
		
		"BLUSH_SPRITESHEET" : {
			0: load_ressource("res://assets/player/face/blush_all.png"),
		},
		
		"LIPSTICK_SPRITESHEET" : {
			0: load_ressource("res://assets/player/face/lipstick .png"),
		},
		
		"EYES_SPRITESHEET" : {
			0: load_ressource("res://assets/player/face/eyes.png"),
		},
		
		"HAIR_SPRITESHEET" : {
			0: load_ressource("res://assets/player/hair/bob .png"),
			1: load_ressource("res://assets/player/hair/braids.png"),
			2: load_ressource("res://assets/player/hair/buzzcut.png"),
			3: load_ressource("res://assets/player/hair/curly.png"),
			4: load_ressource("res://assets/player/hair/emo.png"),
			5: load_ressource("res://assets/player/hair/extra_long.png"),
			6: load_ressource("res://assets/player/hair/french_curl.png"),
			7: load_ressource("res://assets/player/hair/gentleman.png"),
			8: load_ressource("res://assets/player/hair/long_straight .png"),
			9: load_ressource("res://assets/player/hair/long_straight_skirt.png"),
			10: load_ressource("res://assets/player/hair/midiwave.png"),
			11: load_ressource("res://assets/player/hair/ponytail .png"),
			12: load_ressource("res://assets/player/hair/spacebuns.png"),
			13: load_ressource("res://assets/player/hair/wavy.png"),
		},
	}
	
	print("CONSTANTS: Loaded!")


# Method to stop preloading -> is called if game is closed while loading/StartScreen
func stop_preloading():
	preload_stopped = true


# Method to load the resources
# Returns Resource
func load_ressource(path):
	# Check if preload is canceled
	if preload_stopped:
		return
	
	var loader = ResourceLoader.load_interactive(path)
	set_process(true)
	
	while true:
		var err = loader.poll()
		
		if err == ERR_FILE_EOF: # Finished loading.
			return loader.get_resource()


func load_valid_window_sizes():
	var current_window_size = OS.get_screen_size()
	for window_size_dic in Constants.WINDOW_SIZES.values():
		if window_size_dic.value < current_window_size:
			valid_window_sizes.append(window_size_dic)


# Returns the current window_size
func get_valid_window_sizes() -> Array:
	return valid_window_sizes
