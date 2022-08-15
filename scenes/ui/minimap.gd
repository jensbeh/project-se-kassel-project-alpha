extends TextureRect

onready var grassland = load(Constants.MINIMAP_GRASSLAND)
onready var camp = load(Constants.MINIMAP_CAMP)
var atlas
var zoom_factor = 0.1
var zoom

var worldsize = Vector2(2816,1792) #your world size
var player = Utils.get_current_player()


# Initial and size
func _ready():
	atlas = AtlasTexture.new()
	texture = atlas
	zoom = worldsize * zoom_factor
	atlas.set_region(Rect2(0,0, zoom.x, zoom.y))


# Move with player and showing position
func moveMapWithPlayer():
	if atlas.get_atlas() != null and player != null:
		#half resolution , used to keep player centered in minimap
		var half_res = zoom / 2 
		half_res.x = -half_res.x
		var pos = player.position - half_res
		
		#clamp
		pos.x = clamp(pos.x,0, worldsize.x)
		pos.y = clamp(pos.y,0, worldsize.y)
		material.set_shader_param("pos",pos / worldsize)

func _process(_delta):
	moveMapWithPlayer()


# Switch texture when change scene
func update_minimap():
	match Utils.get_scene_manager().get_current_scene_type():
		Constants.SceneType.CAMP:
			worldsize = Vector2(2816,1792)
			atlas.set_atlas(camp)
		Constants.SceneType.GRASSLAND:
			worldsize = Vector2(6400,3328)
			atlas.set_atlas(grassland)
		Constants.SceneType.DUNGEON:
			atlas.set_atlas(null)
			worldsize = Vector2.ZERO
		Constants.SceneType.MENU:
			atlas.set_atlas(null)
			worldsize = Vector2.ZERO
			
	# Not visible in Menu
	if atlas.get_atlas() == null:
		Utils.get_scene_manager().get_node("UI").get_node("Minimap").visible = false
	else:
		Utils.get_scene_manager().get_node("UI").get_node("Minimap").visible = true
		
	player = Utils.get_current_player()


# Scroll over map to zoom in and out 
func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_factor += 0.01
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_factor -= 0.01
		if zoom_factor <= 0:
			zoom_factor = 0.01
		elif zoom_factor > 1:
			zoom_factor = 1
		zoom = zoom_factor * worldsize
		atlas.set_region(Rect2(0,0, zoom.x, zoom.y))
