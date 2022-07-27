extends Node

var pathfinder_thread = Thread.new()
var mobs_to_update : Dictionary = {}
var enemies_to_update = []
var ambient_mobs_to_update = []
var navigation : Navigation2D
var ambient_navigation : Navigation2D
var generate_ambient_mobs_path : bool = false

func _ready():
	pass
	
func init(init_navigation : Navigation2D, init_ambient_navigation : Navigation2D = null):
	navigation = init_navigation
	
	if init_ambient_navigation != null:
		generate_ambient_mobs_path = true
		ambient_navigation = init_ambient_navigation

func _physics_process(_delta):
	if !pathfinder_thread.is_active():
		var enemies = get_tree().get_nodes_in_group("Enemy")
		var ambient_mobs = get_tree().get_nodes_in_group("Ambient Mob")
		if mobs_to_update.size() > 0:
			mobs_to_update.clear()
		
		if enemies.size() > 0:
			enemies_to_update.clear()
			for enemy in enemies:
				if enemy.mob_need_path:
					enemies_to_update.append(enemy)
			if enemies_to_update.size() > 0:
				mobs_to_update["enemies"] = enemies_to_update
		
		if ambient_mobs.size() > 0:
			ambient_mobs_to_update.clear()
			for ambient_mob in ambient_mobs:
				if ambient_mob.mob_need_path:
					ambient_mobs_to_update.append(ambient_mob)
			if ambient_mobs_to_update.size() > 0:
				mobs_to_update["ambient_mobs"] = ambient_mobs_to_update
		
		if mobs_to_update.size() > 0:
			pathfinder_thread.start(self, "generate_pathes", mobs_to_update)


func generate_pathes(mobs_dic : Dictionary):
	# Generate new pathes and send to mobs
	for mob_key in mobs_dic.keys():
		if "enemies" == mob_key:
			for enemy in mobs_dic[mob_key]:
				var target_pos = enemy.get_target_position()
				if target_pos == null:
					# If target_pos is null then take last position of enemy
					target_pos = enemy.global_position
				var new_path = navigation.get_simple_path(enemy.global_position, target_pos, false)
				call_deferred("send_path_to_mob", enemy, new_path)
		
		elif "ambient_mobs" == mob_key:
			for ambient_mob in mobs_dic[mob_key]:
				var target_pos = ambient_mob.get_target_position()
				if target_pos == null:
					# If target_pos is null then take last position of ambient_mob
					target_pos = ambient_mob.global_position
				var new_path = ambient_navigation.get_simple_path(ambient_mob.global_position, target_pos, false)
				call_deferred("send_path_to_mob", ambient_mob, new_path)
	
	call_deferred("task_finished")


func send_path_to_mob(mob, new_path):
	mob.call_deferred("update_path", new_path)


func task_finished():
	# Wait for thread to finish
	pathfinder_thread.wait_to_finish()

