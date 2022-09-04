extends TextureRect

onready var grassland = load(Constants.MINIMAP_GRASSLAND)
onready var camp = load(Constants.MINIMAP_CAMP)
var atlas
var zoom_factor = 0.2
var max_zoom_factor = 0.3
var min_zoom_factor = 0.1
var zoom

var worldsize = Vector2(2816,1792) # World size
var player = Utils.get_current_player()
var min_pos_camp = Vector2(-256,0) # offset camp map
var min_pos_grassland = Vector2(-4352,-2304) # offset grassland map
var min_pos
var min_camp_l = 310
var min_camp_b = 1390
var min_camp_t = 196
var min_camp_r = 1985
var min_grassland_l = -4402#-4352
var min_grassland_b = 840
var min_grassland_t = -2100
var min_grassland_r = 1910#1760
var region = "camp"


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
		var pos = player.position - min_pos - half_res
		var origin_pos = atlas.get_region()
		if region == "camp":
			if (pos.x > min_camp_l - min_pos.x and pos.x <= min_camp_r - zoom.x - min_pos.x):
				atlas.set_region(Rect2(pos.x,origin_pos.position.y,zoom.x,zoom.y))
				origin_pos.position.x = pos.x
			if (pos.y > min_camp_t - min_pos.y and pos.y <= min_camp_b - zoom.y - min_pos.y):
				atlas.set_region(Rect2(origin_pos.position.x,pos.y,zoom.x,zoom.y))
		elif region == "grassland":
			if (pos.x > min_grassland_l - min_pos.x and pos.x <= min_grassland_r - zoom.x - min_pos.x):
				atlas.set_region(Rect2(pos.x,origin_pos.position.y,zoom.x,zoom.y))
				origin_pos.position.x = pos.x
			if (pos.y > min_grassland_t - min_pos.y and pos.y <= min_grassland_b - zoom.y - min_pos.y):
				atlas.set_region(Rect2(origin_pos.position.x,pos.y,zoom.x,zoom.y))
		
func _process(_delta):
	move_map_with_player()


# Switch texture when change scene
func update_minimap():
	match Utils.get_scene_manager().get_current_scene_type():
		Constants.SceneType.CAMP:
			worldsize = Vector2(2816,1792)
			atlas.set_atlas(camp)
			min_pos = min_pos_camp
			region = "camp"
			max_zoom_factor = 0.3
			min_zoom_factor = 0.1
			zoom_factor = 0.2
		Constants.SceneType.GRASSLAND:
			worldsize = Vector2(6400,3328)
			atlas.set_atlas(grassland)
			min_pos = min_pos_grassland
			region = "grassland"
			max_zoom_factor = 0.2
			min_zoom_factor = 0.05
			zoom_factor = 0.125
		Constants.SceneType.DUNGEON:
			atlas.set_atlas(null)
			worldsize = Vector2.ZERO
			min_pos = Vector2.ZERO
			region = ""
		Constants.SceneType.MENU:
			atlas.set_atlas(null)
			worldsize = Vector2.ZERO
			min_pos = Vector2.ZERO
			region = ""
	
	zoom = worldsize * zoom_factor
	if region == "grassland":
		atlas.set_region(Rect2(min_grassland_l - zoom.x - min_pos.x, min_grassland_b - zoom.y - min_pos.y, zoom.x, zoom.y))
	elif region == "camp":
		atlas.set_region(Rect2(min_camp_l - zoom.x - min_pos.x, min_camp_t - zoom.y - min_pos.y, zoom.x, zoom.y))
	
	# Not visible in Menu
	if atlas.get_atlas() == null:
		Utils.get_scene_manager().get_node("UI").get_node("Minimap").visible = false
	else:
		Utils.get_scene_manager().get_node("UI").get_node("Minimap").visible = true
		
	player = Utils.get_current_player()
	if player != null:
		check_pos(player.position - min_pos - (zoom/2))


# Scroll over map to zoom in and out 
func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_factor += 0.005
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_factor -= 0.005
		if zoom_factor <= min_zoom_factor:
			zoom_factor = min_zoom_factor
		elif zoom_factor > max_zoom_factor:
			zoom_factor = max_zoom_factor
		zoom = zoom_factor * worldsize
		check_pos(atlas.get_region().position)


func check_pos(origin_pos):
	if region == "camp":
		if origin_pos.x <= min_camp_l - min_pos.x:
			atlas.set_region(Rect2(min_camp_l - min_pos.x,origin_pos.y,zoom.x,zoom.y))
		elif origin_pos.x >= min_camp_r - zoom.x - min_pos.x:
			atlas.set_region(Rect2(min_camp_r - zoom.x - min_pos.x,origin_pos.y,zoom.x,zoom.y))
		elif player.position.x - min_pos.x - (zoom.x/2) >= min_camp_l - min_pos.x and player.position.x - min_pos.x - (zoom.x/2) <= min_camp_r - zoom.x - min_pos.x:
			atlas.set_region(Rect2(player.position.x - min_pos.x - (zoom.x/2),origin_pos.y,zoom.x,zoom.y))
		elif player.position.x - min_pos.x - (zoom.x/2) <= min_camp_l - min_pos.x:
			atlas.set_region(Rect2(min_camp_l - zoom.x - min_pos.x,origin_pos.y,zoom.x,zoom.y))
		elif player.position.x - min_pos.x - (zoom.x/2) >= min_camp_r - zoom.x - min_pos.x:
			atlas.set_region(Rect2(min_camp_r - zoom.x - min_pos.x,origin_pos.y,zoom.x,zoom.y))
		
		origin_pos = atlas.get_region().position
		if origin_pos.y <= min_camp_t - min_pos.y: 
			atlas.set_region(Rect2(origin_pos.x,min_camp_t - min_pos.y,zoom.x,zoom.y))
		elif origin_pos.y >= min_camp_b - zoom.y - min_pos.y:
			atlas.set_region(Rect2(origin_pos.x,min_camp_b - zoom.y - min_pos.y,zoom.x,zoom.y))
		elif player.position.y - min_pos.y - (zoom.y/2) >= min_camp_t - min_pos.y and player.position.y - min_pos.y - (zoom.y/2) <= min_camp_b - zoom.y - min_pos.y:
			atlas.set_region(Rect2(origin_pos.x,player.position.y - min_pos.y - (zoom.y/2),zoom.x,zoom.y))
		elif player.position.y - min_pos.y - (zoom.y/2) <= min_camp_t - min_pos.y:
			atlas.set_region(Rect2(origin_pos.x,min_camp_t - min_pos.y,zoom.x,zoom.y))
		elif player.position.y - min_pos.y - (zoom.y/2) >= min_camp_b - zoom.y - min_pos.y:
			atlas.set_region(Rect2(origin_pos.x,min_camp_b - zoom.y - min_pos.y,zoom.x,zoom.y))
		
	elif region == "grassland":
		if origin_pos.x <= min_grassland_l - min_pos.x:
			atlas.set_region(Rect2(min_grassland_l - min_pos.x,origin_pos.y,zoom.x,zoom.y))
		elif origin_pos.x >= min_grassland_r - zoom.x - min_pos.x:
			atlas.set_region(Rect2(min_grassland_r - zoom.x - min_pos.x,origin_pos.y,zoom.x,zoom.y))
		elif player.position.x - min_pos.x - (zoom.x/2) >= min_grassland_l - min_pos.x and player.position.x - min_pos.x - (zoom.x/2) <= min_grassland_r - zoom.x - min_pos.x:
			atlas.set_region(Rect2(player.position.x - min_pos.x - (zoom.x/2),origin_pos.y,zoom.x,zoom.y))
		elif player.position.x - min_pos.x - (zoom.x/2) <= min_grassland_l - min_pos.x:
			atlas.set_region(Rect2(min_grassland_l - min_pos.x,origin_pos.y,zoom.x,zoom.y))
		elif player.position.x - min_pos.x - (zoom.x/2) >= min_grassland_r - zoom.x - min_pos.x:
			atlas.set_region(Rect2(min_grassland_r - zoom.x - min_pos.x,origin_pos.y,zoom.x,zoom.y))
		
		origin_pos = atlas.get_region().position
		if origin_pos.y <= min_grassland_t - min_pos.y: 
			atlas.set_region(Rect2(origin_pos.x,min_grassland_t - min_pos.y,zoom.x,zoom.y))
		elif origin_pos.y >= min_grassland_b - zoom.y - min_pos.y:
			atlas.set_region(Rect2(origin_pos.x,min_grassland_b - zoom.y - min_pos.y,zoom.x,zoom.y))
		elif player.position.y - min_pos.y - (zoom.y/2) >= min_grassland_t - min_pos.y and player.position.y - min_pos.y - (zoom.y/2) <= min_grassland_b - zoom.y - min_pos.y:
			atlas.set_region(Rect2(origin_pos.x,player.position.y - min_pos.y - (zoom.y/2),zoom.x,zoom.y))
		elif player.position.y - min_pos.y - (zoom.y/2) <= min_grassland_t - min_pos.y:
			atlas.set_region(Rect2(origin_pos.x,min_grassland_t - min_pos.y,zoom.x,zoom.y))
		elif player.position.y - min_pos.y - (zoom.y/2) >= min_grassland_b - zoom.y - min_pos.y:
			atlas.set_region(Rect2(origin_pos.x,min_grassland_b - zoom.y - min_pos.y,zoom.x,zoom.y))
			
