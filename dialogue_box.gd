extends CanvasLayer

var dialogPath = null
var textSpeed = 0.05

var dialog

var phraseNum = 0
var finished = false

func _ready():
	self.get_parent().connect("interacted", self, "start")
	$DialogueBox.visible = false
	$HSeparator.visible = false
	$Button.visible = false
	$Name.visible = false
	$Text.visible = false
	dialogPath = "res://assets/dialogue/"+ self.get_parent().name + ".json"

func start():
	$DialogueBox.visible = true
	$HSeparator.visible = true
	$Button.visible = true
	$Name.visible = true
	$Text.visible = true
	$Timer.wait_time = textSpeed
	dialog = getDialog()
	nextPhrase()


func _process(_delta):
	$Skip.visible = finished
	if Input.is_action_just_pressed("e") and $Text.visible_characters > 2:
		if finished:
			nextPhrase()
		else:
			$Text.visible_characters = len($Text.text)

# open dialog text
func getDialog():
	var f = File.new()
	if f.file_exists(dialogPath):
		f.open(dialogPath, File.READ)
		var json = f.get_as_text()
		var output = parse_json(json)
		if typeof(output) == TYPE_ARRAY:
			return output
	return []


func nextPhrase():
	# at end of dialog
	if phraseNum >= len(dialog):
		$DialogueBox.visible = false
		$HSeparator.visible = false
		$Button.visible = false
		$Name.visible = false
		$Text.visible = false
		phraseNum = 0
		finished = false
		Utils.get_current_player().set_player_can_interact(true)
		Utils.get_current_player().set_movement(true)
		Utils.get_current_player().set_movment_animation(true)
		# reset npc interaction state
		for npc in self.get_parent().get_parent().get_children():
			npc.set_interacted(false)
	# show text
	else:
		finished = false
		$Name.bbcode_text = dialog[phraseNum].name + ":"
		$Text.bbcode_text = dialog[phraseNum].text
		$Text.visible_characters = 0
		while $Text.visible_characters < len($Text.text):
			$Text.visible_characters += 1
			$Timer.start()
			yield($Timer, "timeout")
		finished = true
		phraseNum += 1


func _on_Button_pressed():
	if finished:
		nextPhrase()
	else:
		$Text.visible_characters = len($Text.text)
	
