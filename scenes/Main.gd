extends Node2D


onready var game_viewport_container = $Game
onready var game_viewport = $Game/Viewport
onready var minimap = $Minimap
onready var sc = $Game/Viewport/SceneManager/CurrentScene

# Nodes LoadingScreen
onready var black_screen = $LoadingScreen/BlackScreen
onready var loading_screen_animation_player = $LoadingScreen/AnimationPlayerBlackScreen


func _ready():
	# Set world / what game_viewport sees to minimap_viewport
	minimap.setup_viewport(game_viewport)
	
	# Set size of fade screen
	black_screen.rect_size = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))


# Method to set mouse filter on black screen -> called from scene manager
func set_black_screen_mouse_filter(mouse_filter):
	black_screen.mouse_filter = mouse_filter


# Method to play a loading screen animation -> called from scene manager
func play_loading_screen_animation(animaiton_name):
	loading_screen_animation_player.play(animaiton_name)
