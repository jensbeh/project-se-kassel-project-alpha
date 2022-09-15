extends Node2D

var player_in_looting_zone = false
var interacted = false
var mob_type
var in_dungeon: bool
var looted = false
var content = {}
var spawn_position

# start timer for looting time and connect interaction signal with player
func _ready():
	position = spawn_position
	$Timer.wait_time = Constants.LOOTING_TIME
	Utils.get_current_player().connect("player_interact", self, "interaction")
	$Timer.start()


func init(new_spawn_position, mob_name):
	spawn_position = new_spawn_position
	for i in ["Bat", "Fungus", "Ghost", "Orbinaut", "Rat", "Skeleton", "SmallSlime", "Snake", "Zombie", "Boss"]:
		if i in mob_name:
			mob_type = i

# When player enter zone, player can interact
func _on_Area2D_body_entered(body):
	if body == Utils.get_current_player():
		player_in_looting_zone = true


# When player leave zone
func _on_Area2D_body_exited(body):
	if body == Utils.get_current_player():
		player_in_looting_zone = false


# when interacted, open loot panel for looting
func interaction():
	if player_in_looting_zone and !interacted:
		interacted = true
		Utils.get_current_player().set_movement(false)
		Utils.get_current_player().set_movment_animation(false)
		var loot_panel = (load(Constants.LOOT_PANEL_PATH).instance())
		Utils.get_ui().add_child(loot_panel)
		loot_panel.connect("looted", self, "save_loot")
		if !looted:
			looted = true
			loot_panel.set_loot_type(mob_type, in_dungeon)
			loot_panel.loot()
		elif !content.empty():
			loot_panel.set_up_content(content)


func save_loot(loot):
	interacted = false
	content = loot
	if content.empty():
		Utils.get_current_player().disconnect("player_interact", self, "interaction")
		queue_free()


# loot disappear when time is up
func _on_Timer_timeout():
	Utils.get_current_player().disconnect("player_interact", self, "interaction")
	queue_free()
