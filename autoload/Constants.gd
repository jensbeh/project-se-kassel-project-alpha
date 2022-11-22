extends Node


# ----------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------

# DEBUG
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

const CAN_TOGGLE_PLAYER_INVINCIBLE = false # Default: false
var IS_PLAYER_INVINCIBLE = false # Default: false

const CAN_TOGGLE_PLAYER_INFINIT_STAMINA = false # Default: false
var HAS_PLAYER_INFINIT_STAMINA = false # Default: false

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
const CAN_MODIFY_TIME = false # Default: false

# ----------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------


"""
#################
## PLAYER
#################
"""
const NAME_LENGTH = 15
const MAX_LEVEL = 30
const FIRST_SPAWN_POSITION = Vector2(-60, 0)
const FIRST_SPAWN_SCENE = "res://scenes/camp/buildings/House1.tscn"
const PLAYER_WALK_SPEED = 70
const PLAYER_TRANSFORM_SCALE = 0.9
const PLAYER_MAX_LIGHT_ENERGY = 0.8
const PLAYER_STAIR_SPEED_FACTOR = 0.6
const CRITICAL_ATTACK_DAMAGE_FACTOR = 1.5
const NORMAL_ATTACK_MIN_DAMAGE_FACTOR = 0.8
const NORMAL_ATTACK_MAX_DAMAGE_FACTOR = 1.2
const MAX_KNOCKBACK = 4
const WEAPON_STAMINA_USE = 8 # * Weapon weight per hit
const STAMINA_SPRINT = 15 # Points per second
const STAMINA_RECOVER = 10 # Points per second
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
const MERCHANT = "res://assets/data/merchant_inv_data.json"
const INVENTORY_PATH = "res://assets/data/inv_data_file.json"


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
## PATHFINDING
#################
"""
const POINTS_HORIZONTAL_PER_TILE = 3
const POINTS_VERTICAL_PER_TILE = 3
const POINT_SIZE_IN_PIXEL_PER_TILE = ceil(float(TILE_SIZE) / (POINTS_HORIZONTAL_PER_TILE - 1))


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
const MOB_RESPAWN_TIMER = 60.0 # in sec
# Spawn times
enum SpawnTime {
	ONLY_DAY,
	ONLY_NIGHT,
	ALWAYS
}

# Mobs settings
const MOB_SPEED_FACTOR = 2.2
const MOB_PRE_ATTACK_SPEED_FACTOR = 1.2
const MOB_DIFFICULTY = 1.0 # Normal = 1.0
const MobsSettings = {
	# General mob settings
	"GENERAL": {
		"AttackRadius" : 32,
		"MobSpeedFactor" : 2.2,
		"DirectAttackStyleProbability" : 0.5,
	},
	
	# Bat settings
	"BAT": {
		"Health" : 75 * MOB_DIFFICULTY,
		"AttackDamage" : 20 * MOB_DIFFICULTY,
		"Knockback" : 1,
		"Weight" : 10,
		"Experience" : 8 * MOB_DIFFICULTY,
		"SpawnTime" : SpawnTime.ONLY_NIGHT,
		"HuntingSpeed" : 50 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 25 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 50 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Fungus settings
	"FUNGUS": {
		"Health" : 140 * MOB_DIFFICULTY,
		"AttackDamage" : 25 * MOB_DIFFICULTY,
		"Knockback" : 2,
		"Weight" : 40,
		"Experience" : 14 * MOB_DIFFICULTY,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 12 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 25 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 12,
		"MaxSearchingTime" : 18,
	},
	
	# Ghost settings
	"GHOST": {
		"Health" : 90 * MOB_DIFFICULTY,
		"AttackDamage" : 20 * MOB_DIFFICULTY,
		"Knockback" : 1,
		"Weight" : 5,
		"Experience" : 9 * MOB_DIFFICULTY,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 35 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 12 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 35 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Orbinaut settings
	"ORBINAUT": {
		"Health" : 120 * MOB_DIFFICULTY,
		"AttackDamage" : 35 * MOB_DIFFICULTY,
		"Knockback" : 4,
		"Weight" : 35,
		"Experience" : 12 * MOB_DIFFICULTY,
		"SpawnTime" : SpawnTime.ONLY_NIGHT,
		"HuntingSpeed" : 45 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 8 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 45 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Rat settings
	"RAT": {
		"Health" : 80 * MOB_DIFFICULTY,
		"AttackDamage" : 15 * MOB_DIFFICULTY,
		"Knockback" : 1,
		"Weight" : 10,
		"Experience" : 8 * MOB_DIFFICULTY,
		"SpawnTime" : SpawnTime.ONLY_NIGHT,
		"HuntingSpeed" : 35 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 20 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 35 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Skeleton settings
	"SKELETON": {
		"Health" : 150 * MOB_DIFFICULTY,
		"AttackDamage" : 40 * MOB_DIFFICULTY,
		"Knockback" : 3,
		"Weight" : 40,
		"Experience" : 15 * MOB_DIFFICULTY,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 20 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 25 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Small_Slime settings
	"SMALL_SLIME": {
		"Health" : 100 * MOB_DIFFICULTY,
		"AttackDamage" : 20 * MOB_DIFFICULTY,
		"Knockback" : 2,
		"Weight" : 30,
		"Experience" : 10 * MOB_DIFFICULTY,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 12 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 25 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Snake settings
	"SNAKE": {
		"Health" : 80 * MOB_DIFFICULTY,
		"AttackDamage" : 25 * MOB_DIFFICULTY,
		"Knockback" : 1,
		"Weight" : 10,
		"Experience" : 8 * MOB_DIFFICULTY,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 35 * MOB_SPEED_FACTOR,
		"WanderingSpeed" : 20 * MOB_SPEED_FACTOR,
		"PreAttackingSpeed" : MOB_PRE_ATTACK_SPEED_FACTOR * 35 * MOB_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Zombie settings
	"ZOMBIE": {
		"Health" : 160 * MOB_DIFFICULTY,
		"AttackDamage" : 35 * MOB_DIFFICULTY,
		"Knockback" : 3,
		"Weight" : 50,
		"Experience" : 16 * MOB_DIFFICULTY,
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
const BOSS_DIFFICULTY = 1.0 # Normal = 1.0
const BossesSettings = {
	# General boss settings
	"GENERAL": {
		"DetectionRadiusInGrassland" : 60,
		"DetectionRadiusInDungeon" : 100,
		"AttackRadiusInGrassland" : 50.0,
		"AttackRadiusInDungeon" : 50.0,
		"DirectAttackStyleProbability" : 0.5,
	},
	
	# Boss_Fungus settings
	"BOSS_FUNGUS": {
		"Health" : 1000 * BOSS_DIFFICULTY,
		"AttackDamage" : 40 * BOSS_DIFFICULTY,
		"Knockback" : 4,
		"Weight" : 100,
		"Experience" : 10 * BOSS_DIFFICULTY,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 12 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 25 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Boss_Ghost settings
	"BOSS_GHOST": {
		"Health" : 1000 * BOSS_DIFFICULTY,
		"AttackDamage" : 40 * BOSS_DIFFICULTY,
		"Knockback" : 4,
		"Weight" : 50,
		"Experience" : 10 * BOSS_DIFFICULTY,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 35 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 12 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 35 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Boss_Orbinaut settings
	"BOSS_ORBINAUT": {
		"Health" : 1000 * BOSS_DIFFICULTY,
		"AttackDamage" : 40 * BOSS_DIFFICULTY,
		"Knockback" : 4,
		"Weight" : 70,
		"Experience" : 10 * BOSS_DIFFICULTY,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 45 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 8 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 45 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Boss_Skeleton settings
	"BOSS_SKELETON": {
		"Health" : 1000 * BOSS_DIFFICULTY,
		"AttackDamage" : 40 * BOSS_DIFFICULTY,
		"Knockback" : 4,
		"Weight" : 100,
		"Experience" : 10 * BOSS_DIFFICULTY,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 20 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 25 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Boss_Small_Slime settings
	"BOSS_SMALL_SLIME": {
		"Health" : 1000 * BOSS_DIFFICULTY,
		"AttackDamage" : 40 * BOSS_DIFFICULTY,
		"Knockback" : 4,
		"Weight" : 50,
		"Experience" : 10 * BOSS_DIFFICULTY,
		"SpawnTime" : SpawnTime.ALWAYS,
		"HuntingSpeed" : 25 * BOSS_SPEED_FACTOR,
		"WanderingSpeed" : 12 * BOSS_SPEED_FACTOR,
		"PreAttackingSpeed" : BOSS_PRE_ATTACK_SPEED_FACTOR * 25 * BOSS_SPEED_FACTOR,
		"MinSearchingTime" : 6,
		"MaxSearchingTime" : 12,
	},
	
	# Boss_Zombie settings
	"BOSS_ZOMBIE": {
		"Health" : 1000 * BOSS_DIFFICULTY,
		"AttackDamage" : 40 * BOSS_DIFFICULTY,
		"Knockback" : 4,
		"Weight" : 80,
		"Experience" : 10 * BOSS_DIFFICULTY,
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

# Save file pathes
const DEFAULT_PLAYER_INV_PATH = "res://assets/data/inv_data_file.json"
const SAVE_SETTINGS_PATH = "user://game/settings.json"
const SAVE_CHARACTER_PATH = "user://character/"
const SAVE_GAME_PATH = "user://game/"
const SAVE_GAME_PATHFINDING_PATH = SAVE_GAME_PATH + "pathfinding/"


"""
#################
## PRELOADED SCENES
#################
"""
# Preloaded mob scenes
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

# Preloaded boss scenes
const PreloadBossScene = [
	preload("res://scenes/mobs/bosses/Boss_FungusBlue.tscn"),
	preload("res://scenes/mobs/bosses/Boss_FungusBrown.tscn"),
	preload("res://scenes/mobs/bosses/Boss_FungusPurple.tscn"),
	preload("res://scenes/mobs/bosses/Boss_FungusRed.tscn"),

	preload("res://scenes/mobs/bosses/Boss_GhostGreen.tscn"),
	preload("res://scenes/mobs/bosses/Boss_GhostPurple.tscn"),
	preload("res://scenes/mobs/bosses/Boss_GhostWhite.tscn"),

	preload("res://scenes/mobs/bosses/Boss_OrbinautBlue.tscn"),
	preload("res://scenes/mobs/bosses/Boss_OrbinautGreen.tscn"),
	preload("res://scenes/mobs/bosses/Boss_OrbinautOrange.tscn"),
	preload("res://scenes/mobs/bosses/Boss_OrbinautRed.tscn"),

	preload("res://scenes/mobs/bosses/Boss_SkeletonBlue.tscn"),
	preload("res://scenes/mobs/bosses/Boss_SkeletonRed.tscn"),
	preload("res://scenes/mobs/bosses/Boss_SkeletonWhite.tscn"),

	preload("res://scenes/mobs/bosses/Boss_SmallSlimeGreen.tscn"),
	preload("res://scenes/mobs/bosses/Boss_SmallSlimeOrange.tscn"),
	preload("res://scenes/mobs/bosses/Boss_SmallSlimePurple.tscn"),
	preload("res://scenes/mobs/bosses/Boss_SmallSlimeRed.tscn"),

	preload("res://scenes/mobs/bosses/Boss_ZombieBlue.tscn"),
	preload("res://scenes/mobs/bosses/Boss_ZombieGreen.tscn"),
	preload("res://scenes/mobs/bosses/Boss_ZombieGrey.tscn")
]

# Preloaded scenes
const PreloadedScenes = {
	"GoldenKeyScene": preload(GOLDEN_KEY_PATH),
	"CharacterScreenContainer": preload(CHARACTER_SCREEN_CONTAINER_SCRIPT_PATH),
	"GameMenuScene" : preload(GAME_MENU_PATH),
	"SettingScene" : preload(SETTINGS_PATH),
	"TradeInventoryScene" : preload(TRADE_INVENTORY_PATH),
	"DeathScreenScene" : preload(DEATH_SCREEN_PATH),
	"LootPanelScene" : preload(LOOT_PANEL_PATH),
	"LootDropScene" : preload(LOOT_DROP_PATH),
	"TreasureScene" : preload(TREASURE_PATH),
	"DialogScene" : preload(DIALOG_PATH),
	"FullInvMsgScene" : preload(FULL_INV_MSG),
	"TradeInvSlotScene" : preload(TRADE_INV_SLOT),
	"InvSlotScene" : preload(INV_SLOT),
	"TooltipScene" : preload(TOOLTIP),
	"SplitPopupScene" : preload(SPLIT_POPUP),
	"CharacterInterfaceScene" : preload(CHARACTER_INTERFACE_PATH),
}


"""
#################
## MUSIC
#################
"""
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
## SOUNDS
#################
"""
const PreloadedSounds = {
	"Switch" : preload("res://assets/sounds/switch6.wav"),
	"Click" : preload("res://assets/sounds/click3.wav"),
	"Choose" : preload("res://assets/sounds/rollover2.wav"),
	"Select" : preload("res://assets/sounds/Menu_Select_00.mp3"),
	"Delete" : preload("res://assets/sounds/UI_027.wav"),
	"Levelup" : preload("res://assets/sounds/snare.wav"),
	"OpenUI" : preload("res://assets/sounds/Inventory_Open_00.mp3"),
	"OpenUI2" : preload("res://assets/sounds/Inventory_Open_01.mp3"),
	"Sucsess" : preload ("res://assets/sounds/Jingle_Achievement_00.mp3"),
	"Lose" : preload("res://assets/sounds/Jingle_Lose_00.mp3"),
	"Win" : preload("res://assets/sounds/Jingle_Win_00.mp3"),
	"Collect" : preload("res://assets/sounds/Pickup_Gold_00.mp3"),
	"Collect2" : preload("res://assets/sounds/chainmail1.wav"),
	"open_door" : preload("res://assets/sounds/doorOpen_2.ogg"),
	"locked" : preload("res://assets/sounds/lockeddoor.wav"),
	"Potion" : preload("res://assets/sounds/bubble.wav"),
	"Potion1" : preload("res://assets/sounds/bubble2.wav"),
	"Dialog" : preload("res://assets/sounds/Pen_v4_wav.wav"),
	"Equip" : preload("res://assets/sounds/SetSomething.ogg"),
	"open_close" : preload("res://assets/sounds/interface2.wav"),
	"Steps_Stairs" : preload("res://assets/sounds/stepstone_7.wav"),
	"Steps_Grassland" : preload("res://assets/sounds/grass_footsteps.wav"),
	"Steps_Dungeon" : preload("res://assets/sounds/hard-footstep.mp3"),
	"Steps_Camp" : preload("res://assets/sounds/stepdirt.mp3"),
	"Steps_House" : preload("res://assets/sounds/step.mp3"),
	"Breath" : preload("res://assets/sounds/breath-male.mp3"),
	"Hurt" : preload("res://assets/sounds/hit34.mp3.mp3"),
	"Attack" : preload("res://assets/sounds/swing.wav"),
	"Drop" : preload("res://assets/sounds/plugpull.wav"),
	"Eat" : preload("res://assets/sounds/beads.wav"),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
