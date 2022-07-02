extends ColorRect

# Manages the current lights and informations for the shader

var image = Image.new()
var texture = ImageTexture.new()

var night_screen_color = Color("212121")

func _ready():
	# Create image to store light informations in pixels
	# First pixel row for light stuff like positions, strength, radius
	# Second pixel row for light color
	image.create(128, 2, false, Image.FORMAT_RGBAH)
	material.set_shader_param("night_screen_color", night_screen_color)

func _physics_process(delta):
	update_shader()
	var t = Transform2D(0, Vector2())
	# Use camera for the correct position of the current screen to show correct light positions
	var camera = Utils.get_scene_manager().find_node("Camera2D")
	if camera != null:
			var canvas_transform = camera.get_canvas_transform()
			var top_left = -canvas_transform.origin / canvas_transform.get_scale()
			t = Transform2D(0, top_left * (1 / camera.zoom.x))
#	if Utils.get_scene_manager().get_is_day_night_cycle_in_scene() == true:
#		var camera = Utils.get_current_player().get_node("Camera2D")
#		if camera != null:
#			var canvas_transform = camera.get_canvas_transform()
#			var top_left = -canvas_transform.origin / canvas_transform.get_scale()
#			t = Transform2D(0, top_left)
#			print(t)

	# Set zoom factor in shader for correct scaling
	material.set_shader_param("camera_zoom_factor", camera.zoom.x)
	# Set global transformation in shader for correct pixels and map size
	material.set_shader_param("global_transform", t)

func update_shader():
	# Get all custom_lights in the current scene
	var lights = get_tree().get_nodes_in_group("lights")
	
	# Save light informations in image pixels
	# Light x & y position in red & green pixel channel
	# Light strength in blue channel
	# Light radius in alpha channel
	image.lock()
	for i in lights.size():
		var light = lights[i]
		if light is CustomLight:
			# Set player light position
			if light.get_parent() is KinematicBody2D:
				var light_position = light.position + light.get_parent().position
				image.set_pixel(i, 0, Color( \
						light_position.x +1, light_position.y, \
						light.strength, light.radius))

				# Save light color in second pixel row
				image.set_pixel(i, 1, light.color)
				
			# Set torch, ... light position
			else:
				var light_position = light.position

				image.set_pixel(i, 0, Color( \
						light_position.x +1, light_position.y, \
						light.strength, light.radius))

				# Save light color in second pixel row
				image.set_pixel(i, 1, light.color)
	image.unlock()
	
	# Make texture from the image because only texture can be set in shader
	texture.create_from_image(image)
	
	# Set count of lights and texture to shader
	material.set_shader_param("lights_count", lights.size())
	material.set_shader_param("light_data", texture)
