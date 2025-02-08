extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_restart_pressed() -> void:
	GameManager.is_start = true
	get_tree().paused = false
	get_tree().reload_current_scene()
	GameManager.init_timer()
func _on_back_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
