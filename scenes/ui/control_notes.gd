extends Control

onready var control_tab = get_node("ControlTab")
onready var control = get_node("Control")

func _ready():
	get_node("ControlTab/Label").set_text(tr("CONTROLLS"))
	get_node("Control/Label").set_text(tr("MENU"))
	get_node("Control/Label2").set_text(tr("INTERACTION"))
	get_node("Control/Label3").set_text(tr("INVENTORY"))
	get_node("Control/Label2").set_text(tr("RUN"))
	get_node("Control/Label2").set_text(tr("MOVEMENT"))
	get_node("Control/Panel6/Label").set_text(tr("MOUSE"))
	
func show_hide_control_notes():
	if control_tab.visible:
		control_tab.visible = false
		control.visible = true
	else:
		control_tab.visible = true
		control.visible = false

func in_world(value):
	if value:
		control_tab.visible = true
		control.visible = false
	else:
		control_tab.visible = false
		control.visible = false
