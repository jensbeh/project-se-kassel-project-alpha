extends Node2D

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
	PathfindingService.add_dynamic_obstacle(get_node("StaticBody/CollisionShape2D"), position)


# Method to disconnect all signals
func clear_signals():
	Utils.get_current_player().disconnect("player_interact", self, "interaction")


func init(init_current_spawn_area, init_navigation_tile_map, init_scene_type, init_lootLayer):
	current_spawn_area = init_current_spawn_area
	navigation_tile_map = init_navigation_tile_map
	scene_type = init_scene_type
	lootLayer = init_lootLayer


# When player enter zone, player can interact
func _on_Area2D_body_entered(body):
	if body == Utils.get_current_player():
		player_in_looting_zone = true


# When player leave zone
func _on_Area2D_body_exited(body):
	if body == Utils.get_current_player():
		player_in_looting_zone = false
		interacted = false


# when interacted, open dialog
func interaction():
	if player_in_looting_zone and !interacted:
		interacted = true
		Utils.get_current_player().set_movement(false)
		Utils.get_current_player().set_player_can_interact(false)
		var dialog = load(Constants.DIALOG_PATH).instance()
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
	loot_panel = (load(Constants.LOOT_PANEL_PATH).instance())
	Utils.get_ui().add_child(loot_panel)
	get_node("AnimationPlayer").play("OpenTreasure")
	loot_panel.connect("looted", self, "save_loot")
	if !looted:
		Utils.get_sound_player().stream = Constants.PreloadedSounds.open_door
		Utils.get_sound_player().play(0.03)
		looted = true
		loot_panel.set_loot_type("Treasure3", true)
		loot_panel.loot()
	else:
		loot_panel.set_up_content(content)


func save_loot(loot):
	interacted = false
	content = loot
	loot_panel.disconnect("looted", self, "save_loot")
