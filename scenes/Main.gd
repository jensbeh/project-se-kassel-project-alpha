extends Node2D


onready var game_viewport_container = $Game
onready var game_viewport = $Game/Viewport
onready var minimap_viewport_container = $Minimap
onready var minimap_viewport = $Minimap/Viewport
onready var minimap = $Minimap/Viewport/Camera2D
onready var sc = $Game/Viewport/SceneManager/CurrentScene

var zoom_factor = 1.0
var max_zoom_factor = 1.5
var min_zoom_factor = 1.0


func _ready():
	# Set world / what game_viewport sees to minimap_viewport
	minimap_viewport.world_2d = game_viewport.world_2d
	
	# Set zoom factor for minimap
	minimap.zoom = Vector2(1.5, 1.5) # min: 1; max: 1.5


func _physics_process(_delta):
	# Move map position with player position
	if Utils.get_current_player() != null:
		minimap.position = Utils.get_current_player().global_position
	
	# Handle minimap zoom
	if minimap.zoom != Vector2(zoom_factor, zoom_factor):
		minimap.zoom = Vector2(zoom_factor, zoom_factor)


# Scroll over map to zoom in and out 
func _on_Minimap_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_factor += 0.05
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_factor -= 0.05
		if zoom_factor <= min_zoom_factor:
			zoom_factor = min_zoom_factor
		elif zoom_factor > max_zoom_factor:
			zoom_factor = max_zoom_factor
