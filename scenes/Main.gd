extends Node2D


onready var viewport1 = $Game/Viewport
onready var viewport2 = $Minimap/Viewport
onready var world = $Game/Viewport/Viewport/World
onready var minimap = $Minimap/Viewport/Camera2D
onready var sc = $Game/Viewport/SceneManager/CurrentScene

func _ready():
	viewport2.world_2d = viewport1.world_2d
	minimap.zoom = Vector2(1, 1)


func _physics_process(_delta):
	if Utils.get_current_player() != null:
		minimap.position = Utils.get_current_player().global_position
