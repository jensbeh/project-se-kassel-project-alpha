extends KinematicBody2D


var spawn_position
var mobsNavigationTileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set spawn position
	global_position = spawn_position


# Method to init variables, typically called after instancing
func init(new_spawn_position, new_mobsNavigationTileMap):
	spawn_position = new_spawn_position
	mobsNavigationTileMap = new_mobsNavigationTileMap
