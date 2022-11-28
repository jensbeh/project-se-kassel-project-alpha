extends Control

onready var grid = find_node("GridContainer")
onready var abort_btn = find_node("Abort")

var quest_slot = Constants.PreloadedScenes.QuestSlot
var free_space = 0
var quest_list = ["QUEST1", "QUEST2", "QUEST3"]
var reward_list = ["Gold", "Potion", "Weapon", "Jewel"]

var quest_rewards = {
	"QUEST1": {
		"Gold": 80,
		"Potion": null,
		"Potion_Stack": null,
		"Weapon": null,
		"Weapon_Stack": null,
		"Jewel": "Jewel",
		"Jewel_Stack": 1,
	},
	"QUEST2": {
		"Gold": 50,
		"Potion": 10011,
		"Potion_Stack": 2,
		"Weapon": null,
		"Weapon_Stack": null,
		"Jewel": null,
		"Jewel_Stack": null,
	},
	"QUEST3": {
		"Gold": 50,
		"Potion": null,
		"Potion_Stack": null,
		"Weapon": null,
		"Weapon_Stack": null,
		"Jewel": null,
		"Jewel_Stack": null,
	},
}


# Called when the node enters the scene tree for the first time.
func _ready():
	abort_btn.set_text(tr("ABORT"))
	show_abort_button()


func show_abort_button():
	if Utils.get_player_ui().get_current_quest() != "" and Utils.get_player_ui().get_current_quest() != null:
		abort_btn.show()
	else:
		abort_btn.hide()


# Show quest list
func show_quests():
	get_node("Background").show()
	for quest in quest_list:
		var quest_slot_new = quest_slot.instance()
		quest_slot_new.get_node("Container/Title").set_text(tr(quest))
		quest_slot_new.get_node("Container/Task").set_text(tr(quest + "_TASK"))
		for reward in reward_list:
			if quest_rewards[quest][reward] != null:
				if reward == "Gold":
					quest_slot_new.get_node("Container/Reward").set_text(quest_slot_new.get_node("Container/Reward").get_text() + 
					str(reward + ": " + str(quest_rewards[quest][reward]) + "\n"))
				elif reward == "Jewel":
					quest_slot_new.get_node("Container/Reward").set_text(quest_slot_new.get_node("Container/Reward").get_text() + 
					str(quest_rewards[quest]["Jewel_Stack"]) + " ⨯ " + str(quest_rewards[quest][reward]) + "\n")
				else:
					quest_slot_new.get_node("Container/Reward").set_text(quest_slot_new.get_node("Container/Reward").get_text() + 
					str(quest_rewards[quest][reward + "_Stack"]) + " ⨯ " + tr(GameData.item_data[str(quest_rewards[quest][reward])]["Name"].to_upper()) + "\n")
		grid.add_child(quest_slot_new, true)
	if Utils.get_player_ui().get_current_quest() != "" and Utils.get_player_ui().get_current_quest() != null:
		for quest in grid.get_children():
			quest.get_node("locked").show()
	return true


# Get quest reward
func reward_quest():
	queue_free()
	for npc in Utils.get_scene_manager().get_child(0).get_child(0).find_node("npclayer").get_children():
		npc.set_interacted(false)
	var player = Utils.get_current_player()
	var quest = Utils.get_player_ui().get_current_quest()
	# Check inventory space
	for item in reward_list:
		if quest_rewards[quest][item] != null and item != "Gold":
			free_space -= 1
	for i in range(1,31):
		var slot = "Inv" + str(i)
		if PlayerData.inv_data[slot]["Item"] == null:
			free_space += 1
		if free_space >= 0:
			break
	# Get reward
	if Utils.get_player_ui().is_quest_finished() and free_space >= 0:
		Utils.set_and_play_sound(Constants.PreloadedSounds.Sucsess)
		Utils.get_player_ui().quest_completed()
		for reward in reward_list:
			if quest_rewards[quest][reward] != null:
				if reward == "Gold":
					player.set_gold(player.get_gold() + quest_rewards[quest][reward])
				else:
					if reward == "Jewel":
						var jewel = GameData.jewel_IDs[randi() % 4]
						quest_rewards[quest][reward] = jewel
					for i in range(1,31):
						var slot = "Inv" + str(i)
						if PlayerData.inv_data[slot]["Item"] == null:
							PlayerData.inv_data[slot]["Item"] = quest_rewards[quest][reward]
							PlayerData.inv_data[slot]["Stack"] = quest_rewards[quest][reward + "_Stack"]
							break
		# Close dialog
		Utils.get_current_player().set_player_can_interact(true)
		Utils.get_current_player().set_movement(true)
		Utils.get_current_player().set_movment_animation(true)
		Utils.get_current_player().pause_player(false)
		Utils.save_game(true)
		return true
	else:
		# Full Msg in Dialog
		return false


func _on_Close_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI)
	queue_free()
	Utils.get_current_player().set_player_can_interact(true)
	Utils.get_current_player().set_movement(true)
	Utils.get_current_player().set_movment_animation(true)
	Utils.get_current_player().pause_player(false)
	for npc in Utils.get_scene_manager().get_child(0).get_child(0).find_node("npclayer").get_children():
		npc.set_interacted(false)


# Canceld the Quest
func _on_Abort_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Delete)
	Utils.get_player_ui().quest_completed()
	for quest in grid.get_children():
		quest.get_node("locked").hide()
	abort_btn.hide()
	Utils.save_game(true)
