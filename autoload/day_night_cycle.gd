extends Node

# Time in realtime
# Daytime: 8:00 - 20:00
# Sunset: 20:00 - 22:00
# Night: 22:00 - 6:00
# Sunrise: 6:00 - 8:00

# Signals
signal change_to_daytime
signal change_to_sunset
signal change_to_night
signal change_to_sunrise

# Variables
var current_time = 0.0
var lights_visible = false # when night; day == false
var screen_color : Color

var is_daytime : bool = false
var is_sunset : bool = false
var is_night : bool = false
var is_sunrise : bool = false

# Time
var current_hour = 0
var current_minute = 0
var previouse_current_minute = 0

# Constants
const COMPLETE_DAY_TIME = 1200.0 # 24h -> 20min = 1200s
# Times in sum == COMPLETE_DAY_TIME
const DAY_TIME = COMPLETE_DAY_TIME / 2 # 12h -> 10min = 600s
const SUNSET_TIME = COMPLETE_DAY_TIME / 12 # 2h ->  1.666min = 100s
const NIGHT_TIME = COMPLETE_DAY_TIME / 3 # 8h ->  6.6666min = 400s
const SUNRISE_TIME = COMPLETE_DAY_TIME / 12 # 2h ->  1.666min = 100s

const ONE_HOUR = COMPLETE_DAY_TIME / 24
const ONE_MINUTE = ONE_HOUR / 60
const DAY_TIME_START_OFFSET = 8 # 8h offset == 8 o'clock -> when daytime should start


# Called when the node enters the scene tree for the first time.
func _ready():
	# Calculate real init hours and minutes from current_time
	current_hour = (int(floor(current_time / ONE_HOUR)) + DAY_TIME_START_OFFSET) % 24
	current_minute = int((fmod(current_time, ONE_HOUR) / ONE_HOUR) * 60)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_time += delta
	
	# Calculate real hours and minutes from time
	current_hour = (int(floor(current_time / ONE_HOUR)) + DAY_TIME_START_OFFSET) % 24
	current_minute = int((fmod(current_time, ONE_HOUR) / ONE_HOUR) * 60)
	# Reset current_time on new day	
	if current_time >= COMPLETE_DAY_TIME:
		current_time = 0
	
	# Calls stuff every 1min (ingame time)
	if current_minute != previouse_current_minute:
		previouse_current_minute = current_minute
		print(str(current_hour) + ":" + str(current_minute))
	
	# Daytime
	if current_time <= DAY_TIME:
		if is_daytime == false:
			is_sunrise = false
			is_daytime = true
			change_to_daytime()

		if screen_color != Constants.DAY_COLOR:
			screen_color = Constants.DAY_COLOR

	# Day to Sunset
	elif current_time <= (DAY_TIME + (SUNSET_TIME / 2)):
		if is_sunset == false:
			is_daytime = false
			is_sunset = true
			change_to_sunset()
		
		
		var value = (current_time - DAY_TIME) / (SUNSET_TIME / 2)
		screen_color = Constants.DAY_COLOR.linear_interpolate(Constants.SUNSET_COLOR, value)

	# Sunset to NIGHT
	elif current_time <= (DAY_TIME + SUNSET_TIME):
		var value = (current_time - (DAY_TIME + (SUNSET_TIME / 2))) / (SUNSET_TIME / 2)
		screen_color = Constants.SUNSET_COLOR.linear_interpolate(Constants.NIGHT_COLOR, value)
		
	# Night
	elif current_time <= (DAY_TIME + SUNSET_TIME + NIGHT_TIME):
		if is_night == false:
			is_sunset = false
			is_night = true
			change_to_night()
		
		if screen_color != Constants.NIGHT_COLOR:
			screen_color = Constants.NIGHT_COLOR

	# Night to Sunrise
	elif current_time <= (DAY_TIME + SUNSET_TIME + NIGHT_TIME + (SUNRISE_TIME / 2)):
		if is_sunrise == false:
			is_night = false
			is_sunrise = true
			change_to_sunrise()
		
		var value = (current_time - (DAY_TIME + SUNSET_TIME + NIGHT_TIME)) / (SUNRISE_TIME / 2)
		screen_color = Constants.NIGHT_COLOR.linear_interpolate(Constants.SUNRISE_COLOR, value)
			
	# Sunrise to Day
	elif current_time <= (DAY_TIME + SUNSET_TIME + NIGHT_TIME + SUNRISE_TIME):
		var value = (current_time - (DAY_TIME + SUNSET_TIME + NIGHT_TIME + (SUNRISE_TIME / 2))) / (SUNRISE_TIME / 2)
		screen_color = Constants.SUNRISE_COLOR.linear_interpolate(Constants.DAY_COLOR, value)

# Method to return the current screen color
func get_screen_color():
	return screen_color

# Method is called when day is started to call some actions
func change_to_daytime():
	print("TO DAYTIME")
	emit_signal("change_to_daytime")

# Method is called when sunset is started to call some actions
func change_to_sunset():
	print("TO SUNSET")
	emit_signal("change_to_sunset")

# Method is called when night is started to call some actions
func change_to_night():
	print("TO NIGHT")
	emit_signal("change_to_night")

# Method is called when sunrise is started to call some actions
func change_to_sunrise():
	print("TO SUNRISE")
	emit_signal("change_to_sunrise")
