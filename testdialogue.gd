extends Node2D

@onready var yes_player: AudioStreamPlayer = $YesSounds
@onready var no_player: AudioStreamPlayer = $NoSounds

var yes_clips: Array[AudioStream] = []
var no_clips: Array[AudioStream] = []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
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
	print(Dialogic.get_signal_list())

func _on_dialogic_signal(argument):
	if argument == "choice_yes":
		yes_player.stream = yes_clips.pick_random()
		yes_player.play()
	elif argument == "choice_no":
		no_player.stream = no_clips.pick_random()
		no_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):
	if Dialogic.current_timeline != null:
		return
	
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		Dialogic.start('Dialogue Waiter 2')
		get_viewport().set_input_as_handled()
