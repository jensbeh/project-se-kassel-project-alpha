extends Light2D

var noise = OpenSimplexNoise.new()
var value = 0.0
const MAX_VALUE = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	value = randi() % MAX_VALUE
	
	# Setup noise
	noise.period = 75
	
func _physics_process(_delta):
	value += 1.0
	if (value > MAX_VALUE):
		value = 0.0
		
	var alpha = abs(noise.get_noise_1d(value)) + 0.7
	if alpha > 1.0:
		alpha = 1.0
	
	self.color = Color(color.r, color.g, color.b, alpha)
