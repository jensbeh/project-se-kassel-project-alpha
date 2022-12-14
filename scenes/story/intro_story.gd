extends Node2D


var story
var de = [
	"Wir schreiben das Jahr 2433.",
	"Die Ressourcen und Materialien der Erde wurden",
	"durch die Gier der Menschen komplett erschöpft.",
	"Die Erde ist kein lebensfähiger Planet mehr.",
	"Überall liegt Müll herum und immer mehr Menschen",
	"sterben an Seuchen oder einer CO2 - Vergiftung.",
	"",
	"Eine Forschungseinrichtung plante mit letzter Hoffnung,",
	"eine neue lebensfähige Umgebung für eine Gruppe",
	"von ausgewählten Menschen und Forschern zu finden.",
	"Ein schwarzes Loch wurde entdeckt und erweckte die Hoffnung,",
	"einen neuen Planeten zu finden.",
	"Dort sollte die Gruppe hinreisen,",
	"um ein neues Leben zu starten und um die Menschheit zu retten.",
	"Die Gruppe machte sich auf den Weg.",
	"Die Mission \"Project Alpha\" wurde gestartet.",
	"",
	"Als die Gruppe in das schwarze Loch eintrat,",
	"konnten sie schon auf der anderen Seite ein neues Sonnensystem sehen.",
	"Durch die Gravitation wurden alle Teilnehmer jedoch bewusstlos",
	"und fanden sich Stunden später auf einem fremden Planeten wieder.",
	"Die Menschen waren alle unversehrt,",
	"jedoch war das Raumschiff und die mitgenommenen Ressourcen verschwunden ...",
	"",
	"Ziemlich schnell wurde klar, dass die Gruppe hilflos",
	"und ohne Verteidigung, auf einem fremden Planeten war.",
	"Die Flora erinnerte an die Erde, jedoch ihre Bewohner nicht.",
	"",
	"Die Gruppe errichtete ein kleines Camp am Ufer einer Küste.",
	"Von hier aus konnten sie besser kontrollieren,",
	"aus welcher Richtung potenzielle Gefahren kamen.",
	"Die Menschen aus der Gruppe haben Jobs angefangen,",
	"Häuser errichtet und gaben ihr Bestes,",
	"um auf dem neuen Planeten zu überleben.",
	"",
	"Einer der Menschen bist du! Ein furchtloser Kämpfer,",
	"der sein Camp verteidigt",
	"und unbekannte Orte auf diesem fremden Planeten entdecken will.",
]
var en =  [
	"The year is 2433,",
	"Earth's resources and materials have been completely depleted by human greed.",
	"Earth is no longer a viable planet.",
	"There is garbage everywhere",
	"and more and more people die of epidemics or CO2 - poisoning.",
	"",
	"A research facility planned with last hope",
	"to find a new viable environment for a group of selected people and researchers.",
	"A black hole was discovered and raised the hope, of finding a new planet.",
	"That is where the group should travel, to start a new life and save humanity.",
	"The group set out on a mission.",
	"The mission \"Project Alpha\" was launched.",
	"",
	"As the group entered the black hole,",
	"they could already see a new solar system on the other side.",
	"However, due to gravity,",
	"all the participants fell unconscious",
	"and hours later found themselves on an alien planet.",
	"The people were all unharmed, however,",
	"the spaceship and the resources they had taken with them had disappeared ...",
	"",
	"Fairly quickly it became clear",
	"that the group was helpless and without defense on an alien planet.",
	"The flora was reminiscent of Earth, but its inhabitants were not.",
	"",
	"The group set up a small camp on the shore of a coastline",
	"From here they could better control from which direction potential dangers came.",
	"The people from the group started jobs,",
	"built houses and did their best to survive on the new planet.",
	"",
	"One of the humans is you! A fearless fighter who defends his camp",
	"and wants to discover unknown places on this strange planet.",
] 

onready var line = get_node("StoryContainer/Line")

const line_time = 1

var player_position = Constants.FIRST_SPAWN_POSITION
var view_direction = Vector2(0,1)

var line_timer = 0
var lines = []
var finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.set_and_play_music(Constants.PreloadedMusic.Camp)

	get_node("Skip").set_text(tr("SKIP"))
	
	# Say SceneManager that new_scene is ready
	Utils.get_scene_manager().finish_transition()
	
	if Utils.get_language() == "en":
		story = en
	else:
		story = de
		
	# start story
	add_line()


func _process(delta):
	line_timer += delta * 0.5
	if line_timer >= line_time:
		line_timer -= line_time
		if story.size() > 0:
			add_line()
	if lines.size() > 0:
		for l in lines:
			l.rect_position.y -= 50 * delta
			if l.rect_position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif story.size() == 0 and !finished:
		finish()


func add_line():
	var new_line = line.duplicate()
	new_line.text = story.pop_front()
	lines.append(new_line)
	get_node("StoryContainer").add_child(new_line)


# End Story Screen
func finish():
	if not finished:
		finished = true
		var transition_data = TransitionData.GamePosition.new(Constants.FIRST_SPAWN_SCENE, player_position, view_direction)
		Utils.get_scene_manager().transition_to_scene(transition_data)


# Method to end Story Screen
func _input(event):
	if event.is_action_pressed("esc"):
		finish()


func _on_Skip_pressed():
	Utils.set_and_play_sound(Constants.PreloadedSounds.Click)
	finish()


func destroy_scene():
	pass
