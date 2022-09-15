extends NinePatchRect


onready var minimap_viewport = $ViewportContainer/Viewport
onready var minimap_camera = $ViewportContainer/Viewport/Camera2D

var zoom_factor = 1.0
var max_zoom_factor = 1.5
var min_zoom_factor = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set visibility on start
	visible = false
	
	# Set zoom factor for minimap_camera
	minimap_camera.zoom = Vector2(zoom_factor, zoom_factor) # min: 1; max: 1.5


func _physics_process(_delta):
	# Move map position with player position
	if Utils.get_current_player() != null and is_instance_valid(Utils.get_current_player()) and Utils.get_current_player().is_inside_tree():
		minimap_camera.position = Utils.get_current_player().global_position
	
	# Handle minimap_camera zoom
	if minimap_camera.zoom != Vector2(zoom_factor, zoom_factor):
		minimap_camera.zoom = Vector2(zoom_factor, zoom_factor)


# Method to setup the viewport world2d with game_viewport world2d otherwise there is no content in minimap
func setup_viewport(game_viewport):
	# Set world / what game_viewport sees to minimap_viewport
	minimap_viewport.world_2d = game_viewport.world_2d


# Scroll over map to zoom in and out 
func _on_ViewportContainer_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_factor += 0.05
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_factor -= 0.05
		if zoom_factor <= min_zoom_factor:
			zoom_factor = min_zoom_factor
		elif zoom_factor > max_zoom_factor:
			zoom_factor = max_zoom_factor


# Switch texture when change scene
func update_minimap():
	Utils.get_player_ui().in_dungeon(false)
	match Utils.get_scene_manager().get_current_scene_type():
		Constants.SceneType.CAMP:
			max_zoom_factor = 1.8
			min_zoom_factor = 1.0
			zoom_factor = 1.0
			visible = true
		
		Constants.SceneType.GRASSLAND:
			max_zoom_factor = 2.1
			min_zoom_factor = 1.3
			zoom_factor = 1.3
			visible = true
		
		Constants.SceneType.DUNGEON:
			Utils.get_player_ui().in_dungeon(true)
			visible = false
		
		Constants.SceneType.MENU:
			visible = false
	
	set_camera_limits()


# Method to set new camera limits depending on scene type
func set_camera_limits():
	match Utils.get_scene_manager().get_current_scene_type():
		# Cameralimits from players in specific maps
		Constants.SceneType.CAMP:
			minimap_camera.limit_left = -10000000
			minimap_camera.limit_top = 186
			minimap_camera.limit_right = 10000000
			minimap_camera.limit_bottom = 10000000
		
		Constants.SceneType.GRASSLAND:
			minimap_camera.limit_left = -4335
			minimap_camera.limit_top = -10000000
			minimap_camera.limit_right = 10000000
			minimap_camera.limit_bottom = 794
