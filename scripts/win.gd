extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_stat(kill_count , ammo_used):
	$kill_count.text = str("Enemies defeat: ",kill_count)
	$ammo_used.text = str("Ammo used: ", ammo_used)

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
