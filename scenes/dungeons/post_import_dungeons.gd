extends Node


func post_import(scene):
	print(scene)
	
	# Set lights with script to lightsObject
	var lightsObject = scene.find_node("lights")
	if lightsObject != null and lightsObject.get_children().size() > 0:
		for child in lightsObject.get_children():
			if child is Sprite:
				var sprite_positon = child.position
				print(sprite_positon)
				
				var light = Light2D.new()
				light.texture = load("res://assets/light.png")
				light.position = Vector2(sprite_positon.x + 8, sprite_positon.y - 8)
				light.texture_scale = 0.2
				light.energy = 0.8
				light.color = Color("64ffde7e")
				
				light.set_script(load("res://scenes/dungeons/animated_dungeon_lights.gd"))
				
				lightsObject.add_child(light)
				light.set_owner(scene)
				print("added light")

	print("End")
	return scene