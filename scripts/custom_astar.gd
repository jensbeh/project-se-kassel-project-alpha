# Heuristics from http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html

extends AStar
class_name CustomAstar


# EUCLIDEAN (squared) heuristic - good calculation for 8 directions of movement (right, left, up, down, diagonal ways)
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
