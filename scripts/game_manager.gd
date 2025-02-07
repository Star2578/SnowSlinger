extends Node


var is_start: bool = false

func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("pause"):
		if is_start:
			get_tree().paused = !get_tree().paused
