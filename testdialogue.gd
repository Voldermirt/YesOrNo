extends Node2D

@onready var notification: Control = $GUI/notification
@onready var playername: Control = $GUI/name
@onready var yes_player: AudioStreamPlayer = $YesSounds
@onready var no_player: AudioStreamPlayer = $NoSounds
var timeline_name = ""

var yes_clips: Array[AudioStream] = []
var no_clips: Array[AudioStream] = []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
	yes_clips = [
		preload("res://assets/sound/yes_sound1.wav"),
		preload("res://assets/sound/yes_sound2.wav"),
		preload("res://assets/sound/yes_sound3.wav")		
	]
	
	no_clips = [
		preload("res://assets/sound/no_sound1.mp3"),
		preload("res://assets/sound/no_sound2.wav"),
		preload("res://assets/sound/no_sound3.wav")
	]
		
	Dialogic.signal_event.connect(_on_dialogic_signal)
	timeline_name = 'get name'
	Dialogic.start('get name')

func _on_dialogic_signal(argument):
	if argument == "choice_yes":
		yes_player.stream = yes_clips.pick_random()
		yes_player.play()
	elif argument == "choice_no":
		no_player.stream = no_clips.pick_random()
		no_player.play()
	match argument:
		"name change yes":
			_update_name_display("yes")
		"name change no":
			_update_name_display("no")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_name_display(change: String):
	GameManager.playername += change
	#playername.Panel.Label.text = str(GameManager.playername)
	var label = playername.get_node("Panel/Label") as Label
	label.text = GameManager.playername
	
#func _on_timeline_ended():
	#notification._on_notification(str(GameManager.likeness) + " likeness score");
	#Dialogic.start("dialogue 1")

func _on_timeline_ended() -> void:
	if timeline_name == "get name":
		Dialogic.start("dialogue 1")
		timeline_name = 'dialogue waiter 1'
		playername.visible = false
	elif timeline_name == 'dialogue 1':
		Dialogic.start("dialogue waiter 2")
		timeline_name = 'dialogue waiter 2'

func _input(event: InputEvent):
	if Dialogic.current_timeline != null:
		return
	
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		Dialogic.start('dialogue 1')
		timeline_name = 'dialogue waiter 1'
		get_viewport().set_input_as_handled()
