extends Node2D

var player_in_looting_zone = false
var interacted = false
var spawn_position
var loot_panel
var looted = false
var content = {}

# connect interaction signal with player
func _ready():
	Utils.get_current_player().connect("player_interact", self, "interaction")
	position = spawn_position


func init(current_spawn_area, navigation_tile_map):
	var collision_radius = get_node("Area2D2/CollisionShape2D").shape.radius
	spawn_position = Utils.generate_position_in_mob_area(current_spawn_area, navigation_tile_map, collision_radius, true)


# When player enter zone, player can interact
func _on_Area2D_body_entered(body):
	if body == Utils.get_current_player():
		player_in_looting_zone = true


# When player leave zone
func _on_Area2D_body_exited(body):
	if body == Utils.get_current_player():
		player_in_looting_zone = false
		interacted = false


# when interacted, open loot panel for looting
func interaction():
	if player_in_looting_zone and !interacted:
		interacted = true
		Utils.get_current_player().set_movement(false)
		get_node("AnimationPlayer").play("OpenTreasure")
		loot_panel = (load(Constants.LOOT_PANEL_PATH).instance())
		Utils.get_ui().add_child(loot_panel)
		loot_panel.connect("looted", self, "save_loot")
		if !looted:
			looted = true
			loot_panel.set_loot_type("Treasure3", false)
			loot_panel.loot()
		else:
			loot_panel.set_up_content(content)


func save_loot(loot):
	interacted = false
	content = loot
	loot_panel.disconnect("looted", self, "save_loot")
