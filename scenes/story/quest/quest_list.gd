extends Control

onready var grid = find_node("GridContainer")

var quest_slot = Constants.PreloadedScenes.QuestSlot

var quest_list = ["QUEST1"]
var reward_list = ["Gold"]
var quest_rewards = {
	"QUEST1": {
		"Gold": 1000,
	},
}


# Called when the node enters the scene tree for the first time.
func _ready():
	# abbord
	pass


# Show quest list
func show_quests():
	get_node("Background").show()
	for quest in quest_list:
		var quest_slot_new = quest_slot.instance()
		quest_slot_new.get_node("Container/Title").set_text(tr(quest))
		quest_slot_new.get_node("Container/Task").set_text(tr(quest + "_TASK"))
		for reward in reward_list:
			quest_slot_new.get_node("Container/Reward").set_text(quest_slot_new.get_node("Container/Reward").get_text() + 
			reward + ": " + str(quest_rewards[quest][reward]) + "\n")
		grid.add_child(quest_slot_new, true)
	if Utils.get_player_ui().get_current_quest() != "" and Utils.get_player_ui().get_current_quest() != null:
		for quest in grid.get_children():
			quest.get_node("locked").show()


# Get quest reward
func reward_quest():
	var player = Utils.get_current_player()
	var quest = Utils.get_player_ui().get_current_quest()
	if Utils.get_player_ui().is_quest_finished():
		Utils.get_player_ui().quest_completed()
		for reward in reward_list:
			if reward == "Gold":
				player.set_gold(player.get_gold() + quest_rewards[quest][reward])
			
			


func _on_Close_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.OpenUI)
	queue_free()
	Utils.get_current_player().set_player_can_interact(true)
	Utils.get_current_player().set_movement(true)
	Utils.get_current_player().set_movment_animation(true)
	Utils.get_current_player().pause_player(false)
	for npc in Utils.get_scene_manager().get_child(0).get_child(0).find_node("npclayer").get_children():
		npc.set_interacted(false)
