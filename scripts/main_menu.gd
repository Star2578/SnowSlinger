extends Control


func _on_start():
	GameManager.is_start = true
	get_tree().change_scene_to_file("res://scenes/level1.tscn")

func _on_quit():
	get_tree().quit()

func _loop_bgm():
	$AudioStreamPlayer2D.play()
