extends Control

@onready var timer_label = $clocktimer

func _ready():
	GameManager.timer_updated.connect(_on_timer_updated)

func _on_timer_updated(time_left: int):		
	var mins = fmod(time_left , 60)
	var hrs = time_left / 60
	var format_string = "%02d:%02d AM"
	var actual_string = format_string % [hrs,mins]	

	timer_label.text = str(actual_string)
