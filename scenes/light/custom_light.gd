extends Position2D
class_name CustomLight

# Variables
export (String, "fire", "player") var color_typ = "fire"
export var radius = 20

var fire_color = Color("#00ff00") #64ffde7e
var player_color = Color("#0000ff")
var color = fire_color

var max_radius = radius * 1.04 # 104% of radius
var min_radius = radius * 0.96 # 96% of radius

var max_strength = 0.7
var strength = 0.5
var min_strength = 0.4

var noise = OpenSimplexNoise.new()
var value = 0.0
const MAX_VALUE = 500

func _ready():
	max_radius = radius * 1.04 # 104% of radius
	min_radius = radius * 0.96 # 96% of radius
	randomize()
	value = randi() % MAX_VALUE
	
	# Setup noise
	noise.period = 120
	
	# Setup color
	if "fire" in color_typ:
		color = fire_color
		
	elif "player" in color_typ:
		color = player_color
	
func _physics_process(_delta):
	value += 1.0
	if (value > MAX_VALUE):
		value = 0.0
	
	# Set new light strength
	strength = abs(noise.get_noise_1d(value)) + min_strength
	if strength > max_strength:
		strength = max_strength
	
	# Set new light radius
	radius = abs(noise.get_noise_1d(value)) * radius + min_radius
	if radius > max_radius:
		radius = max_radius
		
func get_color():
	return color
