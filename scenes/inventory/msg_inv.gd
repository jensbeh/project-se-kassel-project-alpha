extends Control


func _ready():
	get_node("Message").set_text(tr("FULL_INV"))
	get_node("AnimationPlayer").play("full_inv")


func remove_Msg():
	queue_free()
