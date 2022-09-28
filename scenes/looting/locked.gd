extends Control

func _ready():
	var label = get_node("Label")
	label.set_text(tr("NEED_KEY"))
	get_node("AnimationPlayer").play("locked")
	
func animation_ended():
	get_parent().remove_child(self)
	queue_free()
