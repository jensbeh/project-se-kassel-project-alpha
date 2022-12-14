extends Node2D


# Variables
var player_in_looting_zone = false
var interacted = false
var loot_panel
var looted = false
var content = {}
var current_spawn_area
var navigation_tile_map
var scene_type
var lootLayer


# connect interaction signal with player
func _ready():
	self.name = "treasure"
	Utils.get_current_player().connect("player_interact", self, "interaction")
	
	var collision_extents = get_node("StaticBody/CollisionShape2D").shape.extents
	var spawn_position = Utils.generate_position_in_mob_area(scene_type, current_spawn_area, navigation_tile_map, collision_extents.x, true, lootLayer)
	position = spawn_position
	print("TREASURE: Spawned treasure at: " + str(position))
	
	# Add treasure to dynamic obstacles in PathfindingService
	PathfindingService.call_deferred("add_dynamic_obstacle", get_node("StaticBody/CollisionShape2D"), position)
	
	# Set here to avoid error "ERROR: FATAL: Index p_index = 30 is out of bounds (count = 30)."
	# Related "https://godotengine.org/qa/142283/game-inconsistently-crashes-what-does-local_vector-h-do"
	yield(get_tree(), "idle_frame") # Wait also a game frame to avoid game crash
	call_deferred("set_states_to_nodes")


func init(init_current_spawn_area, init_navigation_tile_map, init_scene_type, init_lootLayer):
	current_spawn_area = init_current_spawn_area
	navigation_tile_map = init_navigation_tile_map
	scene_type = init_scene_type
	lootLayer = init_lootLayer


# Method to set states to nodes but not in _ready directly -> called with call_deferred
func set_states_to_nodes():
	$Area2D.set_deferred("monitoring", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", false)


# Method to disconnect all signals
func clear_signals():
	Utils.get_current_player().disconnect("player_interact", self, "interaction")


# When player enter zone, player can interact
func _on_Area2D_body_entered(body):
	if body == Utils.get_current_player():
		player_in_looting_zone = true
		Utils.get_current_player().set_player_in_looting_zone(true)


# When player leave zone
func _on_Area2D_body_exited(body):
	if body == Utils.get_current_player():
		player_in_looting_zone = false
		Utils.get_current_player().set_player_in_looting_zone(false)
		interacted = false


# when interacted, open dialog
func interaction():
	if player_in_looting_zone and !interacted and Utils.get_dialogue_box() == null:
		interacted = true
		Utils.get_current_player().set_movement(false)
		Utils.get_current_player().set_player_can_interact(false)
		var dialog = Constants.PreloadedScenes.DialogScene.instance()
		Utils.get_ui().add_child(dialog)
		if !looted:
			dialog.start(self, false, str(3))
		elif content.empty():
			dialog.start(self, true, str(3))
		else:
			dialog.start(self, "open", str(3))


func reset_interaction():
	interacted = false


# called to open the loot panel
func open_loot_panel():
	interacted = true
	loot_panel = Constants.PreloadedScenes.LootPanelScene.instance()
	Utils.get_ui().add_child(loot_panel)
	get_node("AnimationPlayer").play("OpenTreasure")
	loot_panel.connect("looted", self, "save_loot")
	if !looted:
		Utils.set_and_play_sound(Constants.PreloadedSounds.open_door)
		looted = true
		loot_panel.set_loot_type("Treasure3", true)
		loot_panel.loot()
	else:
		Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI2)
		loot_panel.set_up_content(content)


func save_loot(loot):
	interacted = false
	content = loot
	loot_panel.disconnect("looted", self, "save_loot")
