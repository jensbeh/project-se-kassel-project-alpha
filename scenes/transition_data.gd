class_name TransitionData

# Class with information about a transition to a menu scene
class Menu:
	var transition_type = Constants.TransitionType.MENU_SCENE
	var scene_path = null
	
	func _init(next_scene_path: String):
		scene_path = next_scene_path
		
	func get_scene_path():
		return scene_path
		
	func get_transition_type():
		return transition_type
		
	func is_type(type): return type == Menu
	func get_type(): return Menu

# Class with information about a transition to a game scene with area spawning
class GameArea:
	var transition_type = Constants.TransitionType.GAME_SCENE
	var scene_path = null
	var spawn_area_id = null
	var view_direction = null
	
	func _init(next_scene_path: String, desired_spawn_area_id: String, new_view_direction: Vector2):
		scene_path = next_scene_path
		spawn_area_id = desired_spawn_area_id
		view_direction = new_view_direction
		
	func get_scene_path():
		return scene_path
		
	func get_transition_type():
		return transition_type
		
	func get_spawn_area_id():
		return spawn_area_id
		
	func get_view_direction():
		return view_direction
		
	func is_type(type): return type == GameArea
	func get_type(): return GameArea

# Class with information about a transition to a game scene with custom position spawning
class GamePosition:
	var transition_type = Constants.TransitionType.GAME_SCENE
	var scene_path = null
	var player_position = null
	var view_direction = null
	
	func _init(next_scene_path: String, new_player_position: Vector2, new_view_direction: Vector2):
		scene_path = next_scene_path
		player_position = new_player_position
		view_direction = new_view_direction
		
	func get_scene_path():
		return scene_path
		
	func get_player_position():
		return player_position
		
	func get_transition_type():
		return transition_type
		
	func get_view_direction():
		return view_direction
		
	func is_type(type): return type == GamePosition
	func get_type(): return GamePosition
