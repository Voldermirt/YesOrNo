extends Node2D

@onready var notification: Control = $GUI/notification
@onready var playername: Control = $GUI/name
@onready var yes_player: AudioStreamPlayer = $YesSounds
@onready var no_player: AudioStreamPlayer = $NoSounds
var timeline_name = ""
var play_yes: bool = false
var name_pronounce: Array
var oh_no = preload("res://assets/sound/no_oh_no.mp3")

var yes_clips: Array[AudioStream] = []
var no_clips: Array[AudioStream] = []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
	#yes_clips = [
		#preload("res://assets/sound/yes_sound1.wav"),
		#preload("res://assets/sound/yes_sound2.wav"),
		#preload("res://assets/sound/yes_sound3.wav")		
	#]
	#
	#no_clips = [
		#preload("res://assets/sound/no_sound1.mp3"),
		#preload("res://assets/sound/no_sound2.wav"),
		#preload("res://assets/sound/no_sound3.wav"),
		#preload("res://assets/sound/no_sound4.mp3"),
		#preload("res://assets/sound/no_sound5.mp3"),
		#preload("res://assets/sound/no_sound6.mp3"),
		#preload("res://assets/sound/no_sound7.mp3")		
	#]
	
	var folder = ["elliot"].pick_random()
	match folder:
		"elliot":
			yes_clips = [
				preload("res://assets/sound/elliot/yes1.wav"),
				preload("res://assets/sound/elliot/yes2.wav"),
				preload("res://assets/sound/elliot/yes3.wav"),
				preload("res://assets/sound/elliot/yes4.wav"),
				preload("res://assets/sound/elliot/yes5.wav"),
			]
			no_clips = [
				preload("res://assets/sound/elliot/no1.wav"),
				preload("res://assets/sound/elliot/no2.wav"),
				preload("res://assets/sound/elliot/no3.wav"),
				preload("res://assets/sound/elliot/no4.wav"),
				preload("res://assets/sound/elliot/no5.wav"),
			]
	
		
	Dialogic.signal_event.connect(_on_dialogic_signal)
	timeline_name = 'get name'
	Dialogic.start('get name')

func _play_yes() -> void:
	while play_yes:
		yes_player.stream = yes_clips.pick_random()
		yes_player.play()
		var length = yes_player.stream.get_length()
		var pause = randi_range(1, 2)
		await get_tree().create_timer(length + pause).timeout
		
func _on_dialogic_signal(argument):
	if argument == "choice_yes":
		yes_player.stream = yes_clips.pick_random()
		yes_player.pitch_scale = randf_range(0.92, 1.08)
		yes_player.play()
		#if not play_yes:
			#play_yes = true
			#_play_yes()
	elif argument == "choice_no":
		no_player.stream = no_clips.pick_random()
		no_player.play()
	match argument:
		"name change yes":
			name_pronounce.append(1)
			_update_name_display("yes")
		"name change no":
			name_pronounce.append(2)
			_update_name_display("no")
		"oh_no":
			yes_player.stream = oh_no
			yes_player.play()
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _say_name() -> void:
	for e in name_pronounce:
		if e == 1:
			yes_player.stream = yes_clips.pick_random()
			yes_player.play()
			await yes_player.finished
		elif e == 2:
			no_player.stream = no_clips.pick_random()
			no_player.play()
			await no_player.finished
	
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
		_say_name()
		Dialogic.start("dialogue oh no")
		timeline_name = 'dialogue oh no'
		playername.visible = false
	elif timeline_name == 'dialogue oh no':
		Dialogic.start("dialogue 1")
		timeline_name = 'dialogue 1'
	elif timeline_name == 'dialogue 1':
		Dialogic.start("dialogue waiter 2")
		timeline_name = 'dialogue waiter 2'
	elif timeline_name == 'dialogue waiter 2':
		if (GameManager.likeness > 1):
			Dialogic.start("dialogue like")
			timeline_name = 'dialogue like'
		else:
			Dialogic.start("dialogue dislike")
			timeline_name = 'dialogue dislike'

func _input(event: InputEvent):
	if Dialogic.current_timeline != null:
		return
	
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		Dialogic.start('dialogue 1')
		timeline_name = 'dialogue waiter 1'
		get_viewport().set_input_as_handled()
