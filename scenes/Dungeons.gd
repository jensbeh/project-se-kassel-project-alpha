extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	# setup areas to change areaScenes
	setup_objects_areas()


# Method which is called when a body has entered a enter_level_area
func body_entered_enter_level_area(body, enter_level_area):
	if body.name == "Player":
		var next_level_to = enter_level_area.get_meta("next_level")
		print("-> Next level to \""  + str(next_level_to) + "\"")

# Method which is called when a body has exited a enter_level_area
func body_exited_enter_level_area(body, enter_level_area):
	if body.name == "Player":
		print("-> Body \""  + str(body.name) + "\" EXITED enter_level_area \"" + enter_level_area.name + "\"")


# Setup all objects Area2D's on start
func setup_objects_areas():
	var object = find_node("objects")
	for child in object.get_children():
		if "enter_level" in child.name:
			# connect Area2D with functions to handle body action
			child.connect("body_entered", self, "body_entered_enter_level_area", [child])
			child.connect("body_exited", self, "body_exited_enter_level_area", [child])
		elif "player_spawn" in child.name:
			# connect Area2D with functions to handle body action
			find_node("Player").position = Vector2(child.position.x + 5, child.position.y)
