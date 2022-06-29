extends Node2D

# Variables
var thread
var previouse_scene_path = ""
var current_transition_data = null

# Nodes CurrentScreen
onready var current_scene = $CurrentScene
# Nodes LoadingScreen
onready var black_screen = $LoadingScreen/BlackScreen
onready var loading_screen_animation_player = $LoadingScreen/AnimationPlayerBlackScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set size of fade screen
	black_screen.rect_size = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))

# Method to start transition to next scene with transition_data information
func transition_to_scene(transition_data):
	# Update previouse scene path to return to it if necessary
	update_previouse_scene_path()
	
	# Set new and current transition_data
	current_transition_data = transition_data
	
	# Mouse actions will be stopped until transition is done
	black_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Disabel movment & interaction of player
	if Utils.get_current_player() != null:
		Utils.get_current_player().set_movement(false)
		Utils.get_current_player().set_movment_animation(false)
		Utils.get_current_player().set_player_can_interact(false)
	
	# Show black fade/loading screen and load new scene after fading to black
	if current_transition_data.get_transition_type() == Constants.TransitionType.GAME_SCENE:
		loading_screen_animation_player.play("GameFadeToBlack")
	elif current_transition_data.get_transition_type() == Constants.TransitionType.MENU_SCENE:
		loading_screen_animation_player.play("MenuFadeToBlack")

# Method is called from fadeToBlackAnimation after its done
func load_new_scene():
	thread = Thread.new()
	thread.start(self, "_load_scene_in_background")

# Method to load the new scene with a thread in background
func _load_scene_in_background():
	var loader = ResourceLoader.load_interactive(current_transition_data.get_scene_path())
	set_process(true)

	while true:
		var err = loader.poll()
		
		if err == ERR_FILE_EOF: # Finished loading.
#			var resource = thread.wait_to_finish()
			var resource = loader.get_resource()
			var scene = resource.instance()
			pass_data_to_scene(scene)
			# (Only for Dungeons) ONLY A DIRTY FIX / WORKAROUND UNTIL GODOT FIXED THIS BUG: https://github.com/godotengine/godot/issues/39182
			if current_scene.get_child(0).find_node("CanvasModulate") != null:
				current_scene.get_child(0).remove_child(current_scene.get_child(0).find_node("CanvasModulate"))
			
			call_deferred("_on_load_scene_done", scene)
			break
			
# Method is called when thread is done and the scene is loaded - here the scene will be instancing with all information and will be added to current_scene
func _on_load_scene_done(scene):
	# Get scene and pass init data
	thread.wait_to_finish()

	# Add scene to current_scene
	current_scene.get_child(0).queue_free()
	current_scene.call_deferred("add_child", scene)
	
# Method to pass the transition_data to the new scene 
func pass_data_to_scene(scene):
	if current_transition_data.get_transition_type() != Constants.TransitionType.MENU_SCENE:
		scene.set_transition_data(current_transition_data)

# Method must be called from _ready() of the new scene to say that the loading is finished and the transition can be fadeToNormal
func finish_transition():
	print(previouse_scene_path)
	if current_transition_data != null: # In menu it is null
		# When finished setting up new scene fade back to normal
		if current_transition_data.get_transition_type() == Constants.TransitionType.GAME_SCENE:
			
			# Set player scale/movment ability/movment animation/shadow/interaction back to normal
			if Utils.get_current_player().scale != Vector2(Constants.PLAYER_TRANSFORM_SCALE, Constants.PLAYER_TRANSFORM_SCALE):
				Utils.get_current_player().scale = Vector2(Constants.PLAYER_TRANSFORM_SCALE, Constants.PLAYER_TRANSFORM_SCALE)
			if Utils.get_current_player().get_movement() == false:
				Utils.get_current_player().set_movement(true)
			if Utils.get_current_player().get_movment_animation() == false:
				Utils.get_current_player().set_movment_animation(true)
			if Utils.get_current_player().get_visibility("Shadow") == true:
				Utils.get_current_player().set_visibility("Shadow", false)
			if Utils.get_current_player().get_player_can_interact() == false:
				Utils.get_current_player().set_player_can_interact(true)

			
			# Start fade to normal to game
			loading_screen_animation_player.play("GameFadeToNormal")
			
		elif current_transition_data.get_transition_type() == Constants.TransitionType.MENU_SCENE:
			# Start fade to normal to menu
			loading_screen_animation_player.play("MenuFadeToNormal")
			
		# Mouse actions works now again
		black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Method to return the previouse_scene_path
func get_previouse_scene_path():
	return previouse_scene_path
	
# Method to update the previouse_scene_path
func update_previouse_scene_path():
	if current_transition_data != null: # In menu (after start) it is null
		previouse_scene_path = current_transition_data.get_scene_path()
	else:
		previouse_scene_path = "res://scenes/MainMenuScreen.tscn" # On start up

# Methods and stuff for better debugging
const TIMER_LIMIT = 2.0
var timer = 0.0
func _process(delta):
	timer += delta
	if timer > TIMER_LIMIT:
		timer = 0.0
		print("fps: " + str(Engine.get_frames_per_second()))
