extends Control

var player_in_looting_zone = false
var interacted = false

# connect interaction signal with player
func _ready():
	Utils.get_current_player().connect("player_interact", self, "interaction_detected")


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
	if player_in_looting_zone and !interacted and player_has_key():
		interacted = true
		Utils.get_current_player().set_movement(false)
		Utils.get_current_player().set_movment_animation(false)
		Utils.get_ui().add_child(load(Constants.LOOT_PANEL_PATH).instance())
		Utils.get_ui().get_node("LootPanel").set_loot_type("treasure", true)


# check if the player has a key to open the chest
func player_has_key():
	for i in range(1,31):
		if PlayerData.inv_data["Inv" + str(i)]["Item"] == 10022:
			if PlayerData.inv_data["Inv" + str(i)]["Stack"] > 1:
				PlayerData.inv_data["Inv" + str(i)]["Stack"] -= 1
			else:
				PlayerData.inv_data["Inv" + str(i)]["Item"] = null
			return true
	return false
