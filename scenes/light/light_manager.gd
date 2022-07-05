extends ColorRect

# Manages the current lights and informations for the shader

# Variables
var is_day_night_cycle : bool = false # Default on startup -> Menu
var image = Image.new()
var texture = ImageTexture.new()


func _ready():
	# Update shader color depending on scene type
	Utils.get_scene_manager().connect("scene_type_updated", self, "update_shader_color")
	
	DayNightCycle.connect("change_to_daytime", self, "change_to_daytime")
	DayNightCycle.connect("change_to_sunset", self, "change_to_sunset")
	
	# Create image to store light informations in pixels
	# First pixel row for light stuff like positions, strength, radius
	# Second pixel row for light color
	image.create(128, 2, false, Image.FORMAT_RGBAH)
	material.set_shader_param("night_screen_color", Constants.DAY_COLOR)


func _physics_process(_delta):
	update_shader()
	var t = Transform2D(0, Vector2())
	# Use camera for the correct position of the current screen to show correct light positions
	t = update_shader_transformation()
	# Set global transformation in shader for correct pixels and map size
	material.set_shader_param("global_transform", t)
	
	# Set current screen color when day night cycle is enabled depending on the current time
	if is_day_night_cycle:
		material.set_shader_param("night_screen_color", DayNightCycle.get_screen_color())

# Method to set all lights (with all informations) to the shader
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
						light_position.x, light_position.y, \
						light.strength, light.radius))
				# Save light color in second pixel row
				image.set_pixel(i, 1, light.color)
				
			# Set torch, ... light position
			else:
				var light_position = light.position
				image.set_pixel(i, 0, Color( \
						light_position.x, light_position.y, \
						light.strength, light.radius))
				# Save light color in second pixel row
				image.set_pixel(i, 1, light.color)
	image.unlock()
	
	# Make texture from the image because only texture can be set in shader
	texture.create_from_image(image)
	
	# Set count of lights and texture to shader
	material.set_shader_param("lights_count", lights.size())
	material.set_shader_param("light_data", texture)

# Method to set the current camera zoom factor so that the transformation of the shader is correct
func update_shader_transformation():
	if Utils.get_current_player() != null:
		var camera = Utils.get_current_player().get_node("Camera2D")
		var canvas_transform = camera.get_canvas_transform()
		var top_left = -canvas_transform.origin / canvas_transform.get_scale()
		var t = Transform2D(0, top_left * (1 / camera.zoom.x))

		# Set zoom factor in shader for correct scaling
		material.set_shader_param("camera_zoom_factor", camera.zoom.x)
		
		return t

# Method to set the current shader color depending on the day night cycle
func update_shader_color():
	match Utils.get_scene_manager().get_current_scene_type():
		Constants.SceneType.MENU:
			print("LIGHT MANAGER SCENE TYPE CHANGED ----> MENU")
			is_day_night_cycle = false
			material.set_shader_param("night_screen_color", Constants.DAY_COLOR)
			update_lights()
			
		Constants.SceneType.CAMP:
			print("LIGHT MANAGER SCENE TYPE CHANGED ----> CAMP")
			is_day_night_cycle = true
			update_lights()
			
		Constants.SceneType.GRASSLAND:
			print("LIGHT MANAGER SCENE TYPE CHANGED ----> GRASSLAND")
			is_day_night_cycle = true
			update_lights()
			
		Constants.SceneType.DUNGEON:
			print("LIGHT MANAGER SCENE TYPE CHANGED ----> DUNGEON")
			is_day_night_cycle = false
			material.set_shader_param("night_screen_color", Constants.DUNGEON_COLOR)
			update_lights()


# Method returns true if day night cycle is enabled otherwise false
func get_is_day_night_cycle():
	return is_day_night_cycle


# Method to update all lights to be visible or not
func update_lights():
	var lights = get_tree().get_nodes_in_group("lights")
	for light in lights:
		if DayNightCycle.is_daytime and is_day_night_cycle:
			light.hide_light()
		elif !DayNightCycle.is_daytime and is_day_night_cycle:
			light.show_light()
		elif !is_day_night_cycle:
			light.hide_light()
			
# Method to update all lights to be NOT visible -> signal from day_night_cycle_script
func change_to_daytime():
	var lights = get_tree().get_nodes_in_group("lights")
	for light in lights:
		if is_day_night_cycle:
			light.hide_light()

# Method to update all lights to be visible -> signal from day_night_cycle_script
func change_to_sunset():
	var lights = get_tree().get_nodes_in_group("lights")
	for light in lights:
		if is_day_night_cycle:
			light.show_light()
