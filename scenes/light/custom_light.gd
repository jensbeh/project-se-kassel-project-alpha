extends Position2D
class_name CustomLight

# Variables
export(Color, RGBA) var color = Color("#64ffde7e")
export var radius = 20

var max_radius = radius * 1.04 # 104% of radius
var min_radius = radius * 0.96 # 96% of radius

var max_strength = 0.7
var strength = 0.5
var min_strength = 0.4

# Noise
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
	
	DayNightCycle.connect("change_to_daytime", self, "hide_light")
	DayNightCycle.connect("change_to_sunset", self, "show_light")
	
	visible = !DayNightCycle.is_daytime


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


func hide_light():
	print("HIDE LIGHT")
	visible = false
	
func show_light():
	print("SHOW LIGHT")
	visible = true
