extends CanvasLayer

# Variables
var show_fps = false
const FPS_REFRESH_TIME = 0.5
var fps_timer = 0.0

# Nodes
onready var debuggingNode = $DebuggingNode
onready var fpsCountNode = $DebuggingNode/fps/fpsCount
onready var screenSizeValueNode = $DebuggingNode/screenSize/screenSizeValue
onready var screenMaximizedValueNode = $DebuggingNode/screenMaximized/screenMaximizedValue
onready var screenFullscreenValueNode = $DebuggingNode/screenFullscreen/screenFullscreenValue


# Called when the node enters the scene tree for the first time.
func _ready():
	debuggingNode.visible = false


func _input(event):
	######################
	## Only for debugging
	######################
	if Constants.CAN_DEBUG:
		# Debugging window
		if Constants.CAN_TOGGLE_DEBUGGING_WINDOW:
			if event.is_action_pressed("toggle_debugging"):
				debuggingNode.visible = !debuggingNode.visible
				show_fps = !show_fps
				DayNightCycle.set_process(show_fps)
		
		# Time
		if Constants.CAN_MODIFY_TIME:
			if event.is_action_pressed("numpad plus"):
				DayNightCycle.skip_time(1)
				print("GAME: Added one hour")
		# Player invincible
		if Constants.CAN_TOGGLE_PLAYER_INVINCIBLE:
			if event.is_action_pressed("numpad division"):
				if Utils.get_current_player() != null:
					Constants.IS_PLAYER_INVINCIBLE = !Constants.IS_PLAYER_INVINCIBLE
					Utils.get_current_player().make_player_invincible(Constants.IS_PLAYER_INVINCIBLE)
					print("GAME: Player invincible: " + str(Constants.IS_PLAYER_INVINCIBLE))
		# Player infinit stamina
		if Constants.CAN_TOGGLE_PLAYER_INFINIT_STAMINA:
			if event.is_action_pressed("numpad multiply"):
				Constants.HAS_PLAYER_INFINIT_STAMINA = !Constants.HAS_PLAYER_INFINIT_STAMINA
				print("GAME: Player infinit stamina: " + str(Constants.HAS_PLAYER_INFINIT_STAMINA))


func _process(delta):
	######################
	## Only for debugging
	######################
	# Refresh fps
	if show_fps:
		fps_timer += delta
		if fps_timer > FPS_REFRESH_TIME:
			fps_timer = 0.0
			fpsCountNode.text = str(Engine.get_frames_per_second())
			screenSizeValueNode.text = str(OS.get_window_size().x) + " x " + str(OS.get_window_size().y)
			screenMaximizedValueNode.text = str(OS.is_window_maximized())
			screenFullscreenValueNode.text = str(OS.is_window_fullscreen())
