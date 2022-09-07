extends Control

onready var exp_bar = get_node("NinePatchRect/ProgressBar")
onready var clock = get_node("Clock/clock")
onready var exp_value = get_node("NinePatchRect/ProgressBar/EXPValue")
onready var life_bar = get_node("Lifebar")
var hearts = 3


# Load the correct ui settings
func setup_ui():
	exp_bar.max_value = Utils.get_current_player().get_level() * 100
	if Utils.get_current_player().get_level() >= 10:
			change_heart_number(5)
	elif Utils.get_current_player().get_level() >= 5:
			change_heart_number(4)
	else:
		change_heart_number(3)


# Set expbar value
func set_exp(new_value: int):
	exp_value.set_text("EXP: " + str(new_value))
	exp_bar.value = new_value
	# Max exp for level
	if exp_bar.value >= exp_bar.max_value:
		print("###here###")
		var player_level = Utils.get_current_player().get_level()
		Utils.get_current_player().set_level(player_level +1)
		Utils.get_current_player().set_exp(new_value - exp_bar.max_value)
		exp_bar.max_value = (player_level + 1) * 100
		life_bar.value = 100
		# increase max lp by 10 by level up
		Utils.get_current_player().set_max_health(100 + player_level*10)
		Utils.get_current_player().set_current_health(100 + player_level*10)
		# save player
		Utils.get_current_player().save_player_data(Utils.get_current_player().get_data())
		if player_level +1 == 5:
			change_heart_number(4)
		elif player_level +1 == 10:
			change_heart_number(5)

# Clock
func set_time(new_hour, new_minute):
	clock.set_text(str("%02d" % new_hour) + ":" + str("%02d" % new_minute))


# LifeBar its a % display
func set_life(percent_player_health: int):
	# Factor = 100 / 80 -> 20 = empty = 27-37, 62-72
	# 3 beacuse 3 hearts -> 1/3 each
	if hearts == 3:
		if percent_player_health < 34:
			life_bar.value = percent_player_health / 1.25
		elif percent_player_health < 66:
			# Minimum value from this heart + value - maxvalue of heart before / factor
			life_bar.value = 37 + (percent_player_health - 34) / 1.25
		else:
			# Minimum value from this heart + value - maxvalue of heart before / factor		
			life_bar.value = 72 + (percent_player_health - 66) / 1.25
	elif hearts == 4:
		if percent_player_health < 26:
			life_bar.value = percent_player_health / 1.25
		elif percent_player_health < 51:
			life_bar.value = 27 + (percent_player_health - 26) / 1.25
		elif percent_player_health < 76:
			life_bar.value = 53 + (percent_player_health - 51) / 1.25
		else:
			life_bar.value = 79 + (percent_player_health - 76) / 1.25
	elif hearts == 5:
		if percent_player_health < 22:
			life_bar.value = percent_player_health / 1.3
		elif percent_player_health < 41:
			life_bar.value = 23 + (percent_player_health - 22) / 1.3
		elif percent_player_health < 62:
			life_bar.value = 43 + (percent_player_health - 41) / 1.3
		elif percent_player_health < 81:
			life_bar.value = 64 + (percent_player_health - 62) / 1.3
		else:
			life_bar.value = 84 + (percent_player_health - 81) / 1.3


func change_heart_number(number_heart):
	hearts = number_heart
	life_bar.texture_under = load("res://assets/ui/lifebar_background_" + str(number_heart) + ".png")
	life_bar.texture_progress = load("res://assets/ui/lifebar_" + str(number_heart) + ".png")


# position for hotbar with or without minimap
func in_dungeon(value):
	if value:
		get_node("Hotbar").rect_position = Vector2(-916,456)
	else:
		get_node("Hotbar").rect_position = Vector2(-574,456)
