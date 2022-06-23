extends MarginContainer

var style1 = StyleBoxFlat.new()

signal click(id)
signal double_click()

func _ready():
	# create selected style
	style1.set_bg_color(Color(0.4, 0.4, 0.4, 1))
	style1.set_corner_radius_all(5)
	self.set_focus_mode(2)

func change_menu_color():
	self.get_parent().get_child(0).add_stylebox_override("panel", style1)

func _on_MarginContainer_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			# set focus
			emit_signal("click")
			change_menu_color()
			self.grab_focus()
		if event.button_index == BUTTON_LEFT and event.doubleclick:
			emit_signal("double_click")
