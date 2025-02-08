extends Node

@onready var sensitivity_slider = $Pause/Control/Panel/Sens/Sensitivity

var is_start: bool = false
var mouse_sensitivity: float = 0.1
var kill_count:int
var ammo_used:int

var current_time:int = 0
var end_time: int = 360  # Set countdown start time (in seconds)
var timer:Timer
signal timer_updated(time_left)

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
				timer.stop()
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				timer.start()
			
func on_gameover():
	timer.stop()
	current_time = 0
	get_tree().paused = true
	is_start = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	kill_count = 0
	ammo_used = 0
	get_tree().current_scene.add_child(gameover_scene.instantiate())

func on_win():
	timer.stop()
	current_time = 0
	get_tree().paused = true
	is_start = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var scene = win_scene.instantiate()
	scene.set_stat(kill_count , ammo_used)
	kill_count = 0
	ammo_used = 0
	get_tree().current_scene.add_child(scene)
	
func init_timer():
	update_label()
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)  # Connect signal
	timer.start()  # Start the timer
func _on_timer_timeout():
	current_time += 1
	update_label()
	if current_time >= end_time:
		timer.stop()  # Stop the timer when it reaches 0
		on_win()
	else:
		timer.start()  # Restart the timer to continue countdown
func update_label():
	timer_updated.emit(current_time)

func _sensitivity_changed(value: float):
	mouse_sensitivity = value
