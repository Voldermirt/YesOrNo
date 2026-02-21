extends Control

var likeness: int = 0
var fade_tween: Tween = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_visible(false)
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument):
	modulate.a = 1.0
	visible = true
	
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		fade_tween = null

	if argument == "John_liked":
		$Panel/Label.text = "John liked that..."
		fade_out(self, 3.0)
		likeness += 1
		print("way")
	elif argument == "John_disliked":
		$Panel/Label.text = "John disliked that..."
		fade_out(self, 3.0)
		print("no way")
		likeness -= 1

func fade_out(node_to_fade: CanvasItem, duration: float = 1.0) -> void:
	fade_tween = create_tween()
	fade_tween.tween_property(node_to_fade, "modulate:a", 0.0, duration) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
