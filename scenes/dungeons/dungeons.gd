extends Node

# Variables
var next_level_to  = null
var current_dungeon  = null
var player_in_enter_level_area = false

# Variables - Data passed from scene before
var spawning_area_id  = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup player
	setup_player()
	
	# setup areas to change areaScenes and player_spawn
	setup_objects_areas()
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()

func setup_player():
	Utils.get_current_player().setup_player_in_new_scene(find_node("Player"))
	
	# Set position
	var player_spawn_area = null
	for child in find_node("objects").get_children():
		if "player_spawn" in child.name:
			if child.has_meta("spawn_area_id"):
				if child.get_meta("spawn_area_id") == spawning_area_id:
					player_spawn_area = child
					break

	var player_position = Vector2(player_spawn_area.position.x + 5, player_spawn_area.position.y)
	var view_direction = Vector2(0,1)
	Utils.get_current_player().set_spawn(player_position, view_direction)
	
	# Set light
	var light = Utils.get_current_player().get_node("Light2D")
	light.enabled = true
	
	# Replace template player in scene with current_player
	find_node("Player").get_parent().remove_child(find_node("Player"))
	Utils.get_current_player().get_parent().remove_child(Utils.get_current_player())
	find_node("playerlayer").add_child(Utils.get_current_player())

	# Connect signals
	Utils.get_current_player().connect("player_interact", self, "interaction_detected")

# Method to handle collision detetcion dependent of the collision object type
func interaction_detected():
	if player_in_enter_level_area:
		Utils.get_scene_manager().transition_to_scene("res://scenes/dungeons/dungeon" + current_dungeon + "/Dungeon"+ current_dungeon + "-lvl" + next_level_to + ".tscn", Constants.TransitionType.GAME_SCENE, self.name)

func set_spawning_area_id(new_spawning_area_id: String):
	spawning_area_id = new_spawning_area_id

# Method which is called when a body has entered a enter_level_area
func body_entered_enter_level_area(body, enter_level_area):
	if body.name == "Player":
		next_level_to = enter_level_area.get_meta("next_level")
		current_dungeon = enter_level_area.get_meta("current_dungeon")
		player_in_enter_level_area = true
		print("-> Next level to \"" + current_dungeon + "-" + str(next_level_to) + "\"")

# Method which is called when a body has exited a enter_level_area
func body_exited_enter_level_area(body, enter_level_area):
	if body.name == "Player":
		player_in_enter_level_area = false
		print("-> Body \""  + str(body.name) + "\" EXITED enter_level_area \"" + enter_level_area.name + "\"")
		
# Setup all objects Area2D's on start
func setup_objects_areas():
	var object = find_node("objects")
	for child in object.get_children():
		if "enter_level" in child.name:
			# connect Area2D with functions to handle body action
			child.connect("body_entered", self, "body_entered_enter_level_area", [child])
			child.connect("body_exited", self, "body_exited_enter_level_area", [child])
