extends Control


func _ready():
	Utils.get_sound_player().stream = Constants.PreloadedSounds.Denied
	Utils.get_sound_player().play(0.03)
	get_node("Message").set_text(tr("FULL_INV"))
	get_node("AnimationPlayer").play("full_inv")


func remove_Msg():
	get_parent().remove_child(self)
	queue_free()
