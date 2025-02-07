extends Node

@onready var sensitivity_slider = $Pause/Control/Panel/Sens/Sensitivity

var is_start: bool = false
var mouse_sensitivity: float = 0.1

func _input(event):
	if get_tree().paused:
		if event.is_action_pressed("ui_left"):  # Decrease sensitivity
			sensitivity_slider.value -= 0.01
		elif event.is_action_pressed("ui_right"):  # Increase sensitivity
			sensitivity_slider.value += 0.01
	
	if event.is_action_pressed("pause"):
		if is_start:
			get_tree().paused = !get_tree().paused
			$Pause.visible = !$Pause.visible
			if get_tree().paused:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _sensitivity_changed(value: float):
	mouse_sensitivity = value
