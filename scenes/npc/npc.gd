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
var target = null
var time = 0.0
var turn = (randi() % 41) +10
var stay
var interacted = false

onready var animation_tree = $AnimationTree
onready var animation_player = $AnimationPlayer
onready var animation_state = animation_tree.get("parameters/playback")


# inventar
# sprache
func _ready():
	# syncronize time
	time = DayNightCycle.current_minute
	# connect player interaction
	Utils.get_current_player().connect("player_interact", self, "interaction_detected")
	# get npc path
	path_exists = (self.get_parent().get_parent().find_node(self.name + "_Path") != null)
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


func _physics_process(delta):
	time += delta
	if time >= turn:
		time = 0
	# npc follow path
	if path_exists:
		turn = DayNightCycle.ONE_HOUR
		target = patrol_points[patrol_index]
		if position.distance_to(target) < 1 and time < turn*0.92:
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
				if !wayback and patrol_index == patrol_points.size() -1 and time < turn*0.08:
					wayback = true
				if patrol_index > 0 and wayback and !stop:
					patrol_index = patrol_index - 1
					target = patrol_points[patrol_index]
				if patrol_index == 0 and wayback:
					wayback = false
	
	# npc walk / direction
	if !stop and target != null:
		velocity = (target - position).normalized() * walk_speed
	elif stop and Utils.get_current_player() != null:
		velocity = (Utils.get_current_player().position - self.position)
	else:
		# npcs turn random
		if time == 0.0:
			var direction = (randi() % 3) + 1
			if direction == 1:
				velocity = Vector2(0,1)
			if direction == 2:
				velocity = Vector2(1,0)
			if direction == 3:
				velocity = Vector2(-1,0)
	# npc stay sometimes
	if path_exists:
		if patrol_index == patrol_points.size() -1 and time >= turn*0.08 or position.distance_to(target) < 1 and time >= turn*0.92:
			stay = true
		else:
			stay = false
	# npc turn animation
	if stop or target == null or stay:
		animation_tree.active = false
	# npc animation
	if velocity != Vector2.ZERO and !stop and target != null and !stay:
		animation_tree.set("parameters/Idle/blend_position", velocity)
		animation_tree.set("parameters/Walk/blend_position", velocity)
		animation_state.travel("Walk")
	else:
		animation_tree.active = true
		animation_tree.set("parameters/Idle/blend_position", velocity)
		animation_state.travel("Idle")
	# npc walk
	if !stop and target != null and !stay:
		velocity = move_and_slide(velocity)

# when player enter npc zone, npc has to stay
func _on_interactionZone_NPC_body_entered(body):
	if body == Utils.get_current_player():
		player_in_interacting_zone = true
		stop = true

# when player leave npc zone, npc can walk again
func _on_interactionZone_NPC_body_exited(body):
	if body == Utils.get_current_player():
		player_in_interacting_zone = false
		stop = false

# when player interact with npc with "e"
func interaction_detected():
	if player_in_interacting_zone:
		# proof if some interactions in process
		for npc in self.get_parent().get_children():
			if npc != self and npc.get_interaction():
				interacted = true
		if !interacted:
			interacted = true
			Utils.get_current_player().set_player_can_interact(false)
			emit_signal("interacted")
			Utils.get_current_player().set_movement(false)
			Utils.get_current_player().set_movment_animation(false)

# when npc enters stairs to slow down
func _on_interactionZone_NPC_area_entered(area):
	if area.get_parent().name == "stairs":
		walk_speed *= 0.6

# when npc exited stairs to speed up
func _on_interactionZone_NPC_area_exited(area):
	if area.get_parent().name == "stairs":
		walk_speed = 30

# to get interaction state
func get_interaction():
	return interacted

# to set npc is interacting state
func set_interacted(interaction):
	interacted = interaction
