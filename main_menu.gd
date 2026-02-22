extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	GameManager.goto_scene("res://scenes/Scene1.tscn")


func _on_quit_button_pressed() -> void:
	print("swooby")
	get_tree().quit()
