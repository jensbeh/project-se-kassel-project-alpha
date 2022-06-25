extends Node

var current_player : KinematicBody2D = null

func _ready():
	pass

func get_player():
	return get_node("/root/SceneManager/CurrentScene").get_children().back().find_node("Player")

func set_current_player(new_current_player: KinematicBody2D):
	current_player = new_current_player
func get_current_player():
	return current_player


func get_scene_manager():
	return get_node("/root/SceneManager")
	
	
func calculate_and_set_player_spawn(scene: Node, init_transition_data):
	var player_position = Vector2(0,0)
	var view_direction = Vector2(0,0)
	
	if init_transition_data.is_type(TransitionData.GamePosition):
		player_position = init_transition_data.get_player_position()
		view_direction = init_transition_data.get_view_direction()
		
	elif init_transition_data.is_type(TransitionData.GameArea):
		var player_spawn_area = null
		for child in scene.find_node("playerSpawns").get_children():
			if "player_spawn" in child.name:
				if child.has_meta("spawn_area_id"):
					if child.get_meta("spawn_area_id") == init_transition_data.get_spawn_area_id():
						player_spawn_area = child
						break

		player_position = Vector2(player_spawn_area.position.x + 5, player_spawn_area.position.y)
		view_direction = init_transition_data.get_view_direction()
		
	current_player.set_spawn(player_position, view_direction)

