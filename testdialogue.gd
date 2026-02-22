extends Node2D

@onready var yes_sound: AudioStreamPlayer = $YesSounds
@onready var no_sound: AudioStreamPlayer = $NoSounds

# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	print(Dialogic.get_signal_list())

func _on_dialogic_signal(argument):
	if argument == "choice_yes":
		$YesSounds.play()
	elif argument == "choice_no":
		$NoSounds.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):
	if Dialogic.current_timeline != null:
		return
	
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		Dialogic.start('Dialogue Waiter')
		get_viewport().set_input_as_handled()
