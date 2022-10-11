# Heuristics from http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html

extends AStar
class_name CustomAstar

# MANHATTAN - not for diagonal
#func _estimate_cost(from_id, to_id):
#	var from = get_point_position(from_id)
#	var to = get_point_position(to_id)
#	return manhattan_dist(from,to)
#
#func _compute_cost(from_id, to_id):
#	var from = get_point_position(from_id)
#	var to = get_point_position(to_id)
#	return manhattan_dist(from,to)
#
#func manhattan_dist(from,to):
#	var dx = abs(to.x - from.x)
#	var dy = abs(to.y - from.y)
#
#	return dx + dy


# EUCLIDEAN (squared) - good for diagonal
func _estimate_cost(from_id, to_id):
	var from = get_point_position(from_id)
	var to = get_point_position(to_id)
	return euclidean_dist(from,to)

func _compute_cost(from_id, to_id):
	var from = get_point_position(from_id)
	var to = get_point_position(to_id)
	return euclidean_dist(from,to)

func euclidean_dist(from,to):
	var dx = abs(from.x - to.x)
	var dy = abs(from.y - to.y)
	
	var D = 1
	
	return D * (dx * dx + dy * dy)
