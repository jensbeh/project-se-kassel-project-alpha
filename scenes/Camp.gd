extends Node2D

#onready var door = $"camp/Level 1/Buildings/House 3/door/75/CollisionShape2D"

# Called when the node enters the scene tree for the first time.
func _ready():
	#	door.disabled = false
	var player = Utils.get_player()
	player.connect("player_entering_door_signal", self, "enter_door")
	
func enter_door():
	print("ENTER DOOR")
