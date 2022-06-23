extends Node2D

# Variables
var next_scene = ""
var thread
var current_transition_type = null



# Nodes CurrentScreen
onready var current_scene = $CurrentScene
# Nodes LoadingScreen
onready var black_screen = $LoadingScreen/BlackScreen
onready var loading_screen_animation_player = $LoadingScreen/AnimationPlayerBlackScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set size of fade screen
	black_screen.rect_size = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))
	
func transition_to_scene(new_scene: String, transition_type):
	# Show black fade/loading screen and load new scene after fading to black
	next_scene = new_scene
	current_transition_type = transition_type
	
	black_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if current_transition_type == Constants.TransitionType.GAME_SCENE:
		loading_screen_animation_player.play("GameFadeToBlack")
		
	elif current_transition_type == Constants.TransitionType.MENU_SCENE:
		loading_screen_animation_player.play("MenuFadeToBlack")

func load_new_scene():
	thread = Thread.new()
	thread.start(self, "_load_scene_in_background")
	
func _load_scene_in_background():
	var loader = ResourceLoader.load_interactive(next_scene)
	set_process(true)

	while true:
		# Poll your loader.
		var err = loader.poll()
		
		if err == ERR_FILE_EOF: # Finished loading.
			call_deferred("_on_load_scene_done");
			return loader.get_resource();

func _on_load_scene_done():
	var resource = thread.wait_to_finish()
	var scene = resource.instance();
	current_scene.get_child(0).queue_free()
	current_scene.call_deferred("add_child", scene)
	
func finish_transition():
	# set and update player
	
	
	if current_transition_type != null:
		# When finished setting up new scene fade back to normal
		if current_transition_type == Constants.TransitionType.GAME_SCENE:
			
			# Set player scale/movment ability/shadow to normal if coming from menu
			if Utils.get_current_player().scale != Vector2(Constants.PLAYER_TRANSFORM_SCALE, Constants.PLAYER_TRANSFORM_SCALE):
				Utils.get_current_player().scale = Vector2(Constants.PLAYER_TRANSFORM_SCALE, Constants.PLAYER_TRANSFORM_SCALE)
			if Utils.get_current_player().get_movement() == false:
				Utils.get_current_player().set_movement(true)
			if Utils.get_current_player().get_visibility("Shadow") == true:
				Utils.get_current_player().set_visibility("Shadow", false)
			
			# tart fade out
			loading_screen_animation_player.play("GameFadeToNormal")
			
		elif current_transition_type == Constants.TransitionType.MENU_SCENE:
			loading_screen_animation_player.play("MenuFadeToNormal")
			
		black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE

	
func _process(_delta):
	print("fps: " + str(Engine.get_frames_per_second()))
