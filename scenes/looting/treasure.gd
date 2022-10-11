extends Node2D

var player_in_looting_zone = false
var interacted = false
var loot_panel
var looted = false
var content = {}
var current_spawn_area
var navigation_tile_map
var scene_type

# connect interaction signal with player
func _ready():
	self.name = "treasure"
	Utils.get_current_player().connect("player_interact", self, "interaction")
	
	var collision_radius = get_node("Area2D2/CollisionShape2D").shape.radius
	var spawn_position = Utils.generate_position_in_mob_area(scene_type, current_spawn_area, navigation_tile_map, collision_radius, true)
	position = spawn_position


func init(init_current_spawn_area, init_navigation_tile_map, init_scene_type):
	current_spawn_area = init_current_spawn_area
	navigation_tile_map = init_navigation_tile_map
	scene_type = init_scene_type


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
		looted = true
		loot_panel.set_loot_type("Treasure3", true)
		loot_panel.loot()
	else:
		loot_panel.set_up_content(content)


func save_loot(loot):
	interacted = false
	content = loot
	loot_panel.disconnect("looted", self, "save_loot")
