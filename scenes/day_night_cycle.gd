extends CanvasModulate

# Variables
const DAY_COLOR = Color("ffffff")
const SUNSET_COLOR = Color("ff8f53")
const NIGHT_COLOR = Color("212121")
const SUNRISE_COLOR = Color("ff8f53")

const COMPLETE_DAY_TIME = 1200.0 # 24 std -> 20min = 1200s
# Times in sum == COMPLETE_DAY_TIME
const DAY_TIME = COMPLETE_DAY_TIME / 2 # 12 std -> 10min = 600s
const SUNSET_TIME = COMPLETE_DAY_TIME / 12 # 2 std ->  1.666min = 100s
const NIGHT_TIME = COMPLETE_DAY_TIME / 3 # 8 std ->  6.6666min = 400s
const SUNRISE_TIME = COMPLETE_DAY_TIME / 12 # 2 std ->  1.666min = 100s

var current_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_time += delta
	print(current_time)
	
	# Reset timer on new day
	if current_time > COMPLETE_DAY_TIME:
		current_time = 0.0
	
	# Daytime
	if current_time <= DAY_TIME:
		if self.color != DAY_COLOR:
			self.color = DAY_COLOR

	# Day to Sunset
	elif current_time <= (DAY_TIME + (SUNSET_TIME / 2)):
		var value = (current_time - DAY_TIME) / (SUNSET_TIME / 2)
		self.color = DAY_COLOR.linear_interpolate(SUNSET_COLOR, value)

	# Sunset to NIGHT
	elif current_time <= (DAY_TIME + SUNSET_TIME):
		var value = (current_time - (DAY_TIME + (SUNSET_TIME / 2))) / (SUNSET_TIME / 2)
		self.color = SUNSET_COLOR.linear_interpolate(NIGHT_COLOR, value)
	
	# Night
	elif current_time <= (DAY_TIME + SUNSET_TIME + NIGHT_TIME):
		if self.color != NIGHT_COLOR:
			self.color = NIGHT_COLOR

	# Night to Sunrise
	elif current_time <= (DAY_TIME + SUNSET_TIME + NIGHT_TIME + (SUNRISE_TIME / 2)):
		var value = (current_time - (DAY_TIME + SUNSET_TIME + NIGHT_TIME)) / (SUNRISE_TIME / 2)
		print(value)
		self.color = NIGHT_COLOR.linear_interpolate(SUNRISE_COLOR, value)

	# Sunrise to Day
	elif current_time <= (DAY_TIME + SUNSET_TIME + NIGHT_TIME + SUNRISE_TIME):
		var value = (current_time - (DAY_TIME + SUNSET_TIME + NIGHT_TIME + (SUNRISE_TIME / 2))) / (SUNRISE_TIME / 2)
		print(value)
		self.color = SUNRISE_COLOR.linear_interpolate(DAY_COLOR, value)
