extends TextureRect

onready var grassland = load(Constants.MINIMAP_GRASSLAND)
onready var camp = load(Constants.MINIMAP_CAMP)
var atlas
var zoom_factor = 0.2
var zoom

var worldsize = Vector2(2816,1792) # World size
var player = Utils.get_current_player()
var min_pos_camp = Vector2(-256,0) # offset camp map
var min_pos_grassland = Vector2(-4352,-2304) # offset grassland map
var min_pos

# Initial and size
func _ready():
	atlas = AtlasTexture.new()
	texture = atlas
	zoom = worldsize * zoom_factor
	atlas.set_region(Rect2(0,0, zoom.x, zoom.y))


# Move with player and showing position
func move_map_with_player():
	if atlas.get_atlas() != null and player != null:
		# Half resolution , used to keep player centered in minimap
		var half_res = zoom / 2 
		# calculate position with player pos, map offset and center this
		var pos = player.get_global_position() - min_pos - half_res
		
		# Clamp to keep in map
		pos.x = clamp(pos.x,0, worldsize.x)
		pos.y = clamp(pos.y,0, worldsize.y)
		atlas.set_region(Rect2(pos.x,pos.y,zoom.x,zoom.y))

func _process(_delta):
	move_map_with_player()


# Switch texture when change scene
func update_minimap():
	match Utils.get_scene_manager().get_current_scene_type():
		Constants.SceneType.CAMP:
			worldsize = Vector2(2816,1792)
			atlas.set_atlas(camp)
			min_pos = min_pos_camp
		Constants.SceneType.GRASSLAND:
			worldsize = Vector2(6400,3328)
			atlas.set_atlas(grassland)
			min_pos = min_pos_grassland
		Constants.SceneType.DUNGEON:
			atlas.set_atlas(null)
			worldsize = Vector2.ZERO
			min_pos = Vector2.ZERO
		Constants.SceneType.MENU:
			atlas.set_atlas(null)
			worldsize = Vector2.ZERO
			min_pos = Vector2.ZERO
			
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
			zoom_factor += 0.005
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_factor -= 0.005
		if zoom_factor <= 0.05:
			zoom_factor = 0.05
		elif zoom_factor > 0.4:
			zoom_factor = 0.4
		zoom = zoom_factor * worldsize
