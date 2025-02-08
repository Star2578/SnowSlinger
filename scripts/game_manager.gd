extends Node

@onready var sensitivity_slider = $Pause/Control/Panel/Sens/Sensitivity

var is_start: bool = false
var mouse_sensitivity: float = 0.1
var kill_count:int
var ammo_used:int

var win_scene = preload("res://scenes/win.tscn")
var gameover_scene = preload("res://scenes/gameover.tscn")

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

func on_gameover():
	get_tree().paused = true
	is_start = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	kill_count = 0
	ammo_used = 0
	get_tree().current_scene.add_child(gameover_scene.instantiate())

func on_win():
	get_tree().paused = true
	is_start = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var scene = win_scene.instantiate()
	scene.set_stat(kill_count , ammo_used)
	kill_count = 0
	ammo_used = 0
	get_tree().current_scene.add_child(scene)
	
func start_timer():
	var timer = get_tree().get_first_node_in_group("GameTimer")

func _sensitivity_changed(value: float):
	mouse_sensitivity = value
