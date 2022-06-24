extends Node2D

# Variables
var next_scene_path = ""
var data_to_pass = null
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

func transition_to_menu_scene(new_scene_path: String):
	# Show black fade/loading screen and load new scene after fading to black
	print("transition_to_scene_menu")
	next_scene_path = new_scene_path
	current_transition_type = Constants.TransitionType.MENU_SCENE
	
	# Can't click any button
	black_screen.mouse_filter = Control.MOUSE_FILTER_STOP

	loading_screen_animation_player.play("MenuFadeToBlack")

func transition_to_game_scene_area(new_scene_path: String, new_data_to_pass):
	# Show black fade/loading screen and load new scene after fading to black
	print(new_data_to_pass)
	next_scene_path = new_scene_path
	data_to_pass = new_data_to_pass
	current_transition_type = Constants.TransitionType.GAME_SCENE
	
	# Can't click any button
	black_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	
	loading_screen_animation_player.play("GameFadeToBlack")

func load_new_scene():
	thread = Thread.new()
	thread.start(self, "_load_scene_in_background")
	
func _load_scene_in_background():
	var loader = ResourceLoader.load_interactive(next_scene_path)
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
	pass_data_to_scene(scene)
	
	# (Only for Dungeons) ONLY A DIRTY FIX / WORKAROUND UNTIL GODOT FIXED THIS BUG: https://github.com/godotengine/godot/issues/39182
	if current_scene.get_child(0).find_node("CanvasModulate") != null:
		current_scene.get_child(0).remove_child(current_scene.get_child(0).find_node("CanvasModulate"))

	current_scene.get_child(0).queue_free()
	current_scene.call_deferred("add_child", scene)
	
func pass_data_to_scene(scene):
	if "Camp" in scene.name:
		var player_position : Vector2 = data_to_pass
		scene.set_player_spawn(player_position)
		
	elif "Dungeon" in scene.name:
		var spawning_area_id = data_to_pass
		scene.set_spawning_area_id(spawning_area_id)
		print("put dungeon_scene data")
		
	elif "Grassland" in scene.name:
		var spawning_area_id = data_to_pass
		scene.set_spawning_area_id(spawning_area_id)
		print("put grassland_scene data")
		
	
func finish_transition():
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


const TIMER_LIMIT = 2.0
var timer = 0.0
func _process(delta):
	timer += delta
	if timer > TIMER_LIMIT:
		timer = 0.0
		print("fps: " + str(Engine.get_frames_per_second()))
