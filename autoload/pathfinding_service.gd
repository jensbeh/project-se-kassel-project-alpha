extends Node

var pathfinder_thread = Thread.new()
var mobs_to_update = []
var navigation

func _ready():
	pass
	
func init(init_navigation):
	navigation = init_navigation

func _physics_process(_delta):
	if !pathfinder_thread.is_active():
		var enemies = get_tree().get_nodes_in_group("Enemy")
		
		if enemies.size() > 0:
			mobs_to_update.clear()
			for enemy in enemies:
				if enemy.mob_need_path:
					mobs_to_update.append(enemy)
			
		if mobs_to_update.size() > 0:
			pathfinder_thread.start(self, "generate_pathes", mobs_to_update)

func generate_pathes(mobs):
	# Generate new pathes and send to mobs
	for mob in mobs:
		var target_pos = mob.get_target_position()
		if target_pos == null:
			# If target_pos is null then take last position of mob
			target_pos = mob.global_position
		var new_path = navigation.get_simple_path(mob.global_position, target_pos, false)
		call_deferred("send_path_to_mob", mob, new_path)
	
	call_deferred("task_finished")

func send_path_to_mob(mob, new_path):
	mob.call_deferred("update_path", new_path)

func task_finished():
	# Wait for thread to finish
	pathfinder_thread.wait_to_finish()

