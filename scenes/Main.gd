extends Node2D


onready var game_viewport_container = $Game
onready var game_viewport = $Game/Viewport
onready var minimap_viewport_container = $Minimap
onready var minimap_viewport = $Minimap/Viewport
onready var minimap = $Minimap/Viewport/Camera2D
onready var sc = $Game/Viewport/SceneManager/CurrentScene


func _ready():
	# Set world / what game_viewport sees to minimap_viewport
	minimap_viewport.world_2d = game_viewport.world_2d
	
	# Set zoom factor for minimap
	minimap.zoom = Vector2(1.5, 1.5) # min: 1; max: 1.5


func _physics_process(_delta):
	# Move map position with player position
	if Utils.get_current_player() != null:
		minimap.position = Utils.get_current_player().global_position
