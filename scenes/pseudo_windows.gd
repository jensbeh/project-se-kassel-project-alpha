extends Node2D
class_name PseudoWindows


###############################
##
##     !!! IMPORTANT !!!
##
## Children must be ColorRects
##
###############################


# Called when the node enters the scene tree for the first time.
func _ready():
	# Check childs
	# Need at least 1 window
	if get_child_count() == 0:
		printerr("ERROR: PseudoWindow has no Color Rects")
	else:
		# All windows must be ColorRects
		for window in get_windows():
			if not window is ColorRect:
				printerr("ERROR: PseudoWindow is no Color Rect")


func _physics_process(_delta):
	for window in get_windows():
		window.color = DayNightCycle.get_screen_color()


# Returns list of children here known as windows
func get_windows():
	return get_children()
