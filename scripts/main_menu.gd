extends Control

@export var weapons: Array[Weapon]
@export var sprites: Array[Texture2D]

var index = 0

func _ready():
	$Buttons/Start.grab_focus()

func _input(event):
	if event.is_action_pressed("ui_down"):  # D-Pad Down / Left Stick Down
		_move_focus(1)
	elif event.is_action_pressed("ui_up"):  # D-Pad Up / Left Stick Up
		_move_focus(-1)
	elif event.is_action_released("ui_accept"):  # A / Cross Button
		if get_viewport().gui_get_focus_owner():
			get_viewport().gui_get_focus_owner().emit_signal("pressed")

func _move_focus(direction):
	var focused = get_viewport().gui_get_focus_owner()
	if not focused:
		return

	var buttons = $Buttons.get_children()
	var index = buttons.find(focused)

	if index != -1:
		var next_index = (index + direction) % buttons.size()
		buttons[next_index].grab_focus()  # Move focus

func _on_start():
	GameManager.is_start = true
	GameManager.weapon_pri = weapons[index]
	get_tree().change_scene_to_file("res://scenes/level1.tscn")

func _on_quit():
	get_tree().quit()

func _loop_bgm():
	$AudioStreamPlayer2D.play()

func _press_next():
	index = (index + 1) % weapons.size()  # Loops to 0 when reaching the last weapon
	update_weapon_display()
	
func _press_prev():
	index = (index - 1 + weapons.size()) % weapons.size()  # Loops to last weapon when going negative
	update_weapon_display()

func update_weapon_display():
	$ColorRect2/Display.texture = sprites[index]
	$ColorRect2/Display/Label.text = weapons[index].weapon_name
