extends Node2D

@onready var notification: Control = $GUI/notification
@onready var player_name: Control = $GUI/name
@onready var yes_player: AudioStreamPlayer = $YesSounds
@onready var no_player: AudioStreamPlayer = $NoSounds

const MAX_NAME_COUNT: int = 8
const PRONOUNCE_YES := 1
const PRONOUNCE_NO := 2

var timeline_name: String = ""
var play_yes: bool = false
var name_pronounce: Array = []
var name_count: int = 0
var oh_no: AudioStream = preload("res://assets/sound/no_oh_no.mp3")

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
	#nof_clips = [
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
		

func _play_stream(player: AudioStreamPlayer, stream: AudioStream, await_finish: bool=false, randomize_pitch : bool = false) -> void:
	player.stream = stream
	if randomize_pitch:
		player.pitch_scale = randf_range(0.92, 1.08)
	player.play()
	if await_finish:
		await player.finished


func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"choice_yes":
			_play_stream(yes_player, yes_clips.pick_random(), true, true)
		"choice_no":
			_play_stream(no_player, no_clips.pick_random(), true, true)
		"name change yes":
			if name_count < MAX_NAME_COUNT:
				name_pronounce.append(PRONOUNCE_YES)
				_update_name_display("yes")
		"name change no":
			if name_count < MAX_NAME_COUNT:
				name_pronounce.append(PRONOUNCE_NO)
				_update_name_display("no")
		"oh_no":
			_play_stream(yes_player, oh_no)
		"french":
			get_tree().quit()
		"inquisition":
			$SpanishInquisitionSound.play()
			await $SpanishInquisitionSound.finished
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _say_name() -> void:
	for e in name_pronounce:
		if e == PRONOUNCE_YES:
			await _play_stream(yes_player, yes_clips.pick_random(), true, true)
		elif e == PRONOUNCE_NO:
			await _play_stream(no_player, no_clips.pick_random(), true, true)
	
func _update_name_display(change: String) -> void:
	if name_count < MAX_NAME_COUNT:
		name_count += 1
		GameManager.playername += change
		var label = player_name.get_node("Panel/Label") as Label
		label.text = GameManager.playername
	
#func _on_timeline_ended():
	#notification._on_notification(str(GameManager.likeness) + " likeness score");
	#Dialogic.start("dialogue 1")

func _on_timeline_ended() -> void:
	if timeline_name == "get name":
		_say_name()
		var n = randi() % 200
		if (n < 195):
			Dialogic.start("dialogue_intro")
			timeline_name = 'dialogue_intro'
		else:
			Dialogic.start("dialogue oh no")
			timeline_name = 'dialogue oh no'
		player_name.visible = false
	elif timeline_name == 'dialogue oh no':
		Dialogic.start("dialogue_intro")
		timeline_name = 'dialogue_intro'
	elif timeline_name == "dialogue_intro":
		Dialogic.start("dialogue 1")
		timeline_name = "dialogue 1"
	elif timeline_name == 'dialogue 1':
		Dialogic.start("dialogue_where_you_from")
		timeline_name = 'dialogue_where_you_from'
	elif timeline_name == 'dialogue_where_you_from':
		Dialogic.start("dialogue waiter 2")
		timeline_name = 'dialogue waiter 2'
	elif timeline_name == 'dialogue waiter 2':
		if (GameManager.likeness > 1):
			Dialogic.start("dialogue like")
			timeline_name = 'dialogue like'
		else:
			Dialogic.start("dialogue dislike")
			timeline_name = 'dialogue dislike'
	else:
		GameManager.goto_scene("res://scenes/ending.tscn")
		return


func _input(event: InputEvent) -> void:
	if name_count >= MAX_NAME_COUNT:
		name_count -= 1
		Dialogic.end_timeline()
		
	if Dialogic.current_timeline != null:
		return

	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		Dialogic.start('dialogue 1')
		timeline_name = 'dialogue waiter 1'
		get_viewport().set_input_as_handled()
