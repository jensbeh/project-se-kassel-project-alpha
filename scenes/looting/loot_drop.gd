extends Control

var player_in_looting_zone = false
var interacted = false
var mob_type 
var in_dungeon: bool
var loot_type

# todos:
# positon from died mob
# show when mob died
# where was this mob and was it a boss? -> mob_type

# start timer for looting time and connect interaction signal with player
func _ready():
	$Timer.wait_time = Constants.LOOTING_TIME
	Utils.get_current_player().connect("player_interact", self, "interaction_detected")
	$Timer.start()


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
		Utils.get_current_player().set_movment_animation(false)
		Utils.get_ui().add_child(load(Constants.LOOT_PANEL_PATH).instance())
		if mob_type:
			randomize()
			loot_type = "Mob" + str((randi() % 3) + 1)
		else:
			loot_type = "Boss"
		Utils.get_ui().get_node("LootPanel").set_loot_type(loot_type, in_dungeon)


# loot diassapper when time is up
func _on_Timer_timeout():
	queue_free()
