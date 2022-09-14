extends Control

var player_in_looting_zone = false
var interacted = false
var mob_type = true
var in_dungeon: bool
var loot_type
var looted = false
var content = {}
var spawn_position

# todos:
# where was this mob and was it a boss? -> mob_type

# start timer for looting time and connect interaction signal with player
func _ready():
	rect_position = spawn_position
	$Timer.wait_time = Constants.LOOTING_TIME
	Utils.get_current_player().connect("player_interact", self, "interaction")
	$Timer.start()


func init(new_spawn_position, mob_name):
	spawn_position = new_spawn_position
	print(mob_name)
	

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
			if mob_type:
				randomize()
				loot_type = "Mob" + str((randi() % 3) + 1)
			else:
				loot_type = "Boss"
			loot_panel.set_loot_type(loot_type, in_dungeon)
			loot_panel.loot()
		elif !content.empty():
			loot_panel.set_up_content(content)


func save_loot(loot):
	interacted = false
	content = loot
	if content.empty():
		queue_free()


# loot disappear when time is up
func _on_Timer_timeout():
	queue_free()
