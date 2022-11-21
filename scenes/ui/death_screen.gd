extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Sound
	Utils.set_and_play_sound(Constants.PreloadedSounds.Lose)
	
	get_node("Label").set_text(tr("DEATH_MESSAGE"))


# Method is called when fade in animation is done
func on_death_screen_end():
	# Teleport player to graveyard in camp
	var player_position = Vector2(1360,924)
	var view_direction = Vector2(0,1)
	
	# Transition
	var transition_data = TransitionData.GamePosition.new(Constants.CAMP_SCENE_PATH, player_position, view_direction)
	Utils.get_scene_manager().transition_to_scene(transition_data)
	
	DayNightCycle.skip_time(8, false)
