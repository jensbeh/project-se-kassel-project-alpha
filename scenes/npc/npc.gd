extends KinematicBody2D

signal interacted

var player_in_interacting_zone
var patrol_points = []
var patrol_index = 0
var path_1
var velocity = Vector2.ZERO
var wayback = false
var stop = false
var walk_speed = 30
var circle = false
var path_exists

onready var animation_tree = $AnimationTree
onready var animation_player = $AnimationPlayer
onready var animation_state = animation_tree.get("parameters/playback")


# inventar
# stehenbleiben -> 50sec = 1h 
# starre character drehen sich zu player oder random jede stunde mit 30% whrs
# stehen bleiben / verschwinden -> abhängig von zeit
# sprache
func _ready():
	path_exists = (self.get_parent().get_parent().find_node(self.name + "_Path") != null)
	Utils.get_current_player().connect("player_interact", self, "interaction_detected")
	if path_exists:
		path_1 = self.get_parent().get_parent().find_node(self.name + "_Path")
		var points = path_1.get_curve().get_baked_points()
		for i in points:
			i = i + path_1.position
			patrol_points.append(i)
		self.position = patrol_points[0]
		animation_tree.active = true
		animation_tree.set("parameters/Idle/blend_position", velocity)
		animation_tree.set("parameters/Walk/blend_position", velocity)
		if path_1.has_meta("is_circle"):
			circle = path_1.get_meta("is_circle")


func _physics_process(_delta):
	if path_exists:
		var target = patrol_points[patrol_index]
		if position.distance_to(target) < 1:
			if circle:
				if patrol_index < patrol_points.size() -1 and !stop:
					patrol_index = patrol_index + 1
					target = patrol_points[patrol_index]
				if patrol_index == patrol_points.size() -1:
					patrol_index = 0
			else:
				if patrol_index < patrol_points.size() -1 and !wayback and !stop:
					patrol_index = patrol_index + 1
					target = patrol_points[patrol_index]
				if !wayback and patrol_index == patrol_points.size() -1:
					wayback = true
				if patrol_index > 0 and wayback and !stop:
					patrol_index = patrol_index - 1
					target = patrol_points[patrol_index]
				if patrol_index == 0 and wayback:
					wayback = false
		if !stop:
			velocity = (target - position).normalized() * walk_speed
		else:
			velocity = (Utils.get_current_player().position - self.position)
			
		if stop:
			animation_tree.active = false
			
		if velocity != Vector2.ZERO and !stop:
			animation_tree.set("parameters/Idle/blend_position", velocity)
			animation_tree.set("parameters/Walk/blend_position", velocity)
			animation_state.travel("Walk")
		else:
			animation_tree.active = true
			animation_tree.set("parameters/Idle/blend_position", velocity)
			animation_state.travel("Idle")
			
		if !stop:
			velocity = move_and_slide(velocity)


func _on_interactionZone_NPC_body_entered(body):
	if body == Utils.get_current_player():
		player_in_interacting_zone = true
		stop = true


func _on_interactionZone_NPC_body_exited(body):
	if body == Utils.get_current_player():
		player_in_interacting_zone = false
		stop = false


func interaction_detected():
	if player_in_interacting_zone:
		Utils.get_current_player().set_player_can_interact(false)
		emit_signal("interacted")


func _on_interactionZone_NPC_area_entered(area):
	if area.get_parent().name == "stairs":
		walk_speed *= 0.6


func _on_interactionZone_NPC_area_exited(area):
	if area.get_parent().name == "stairs":
		walk_speed = 30

