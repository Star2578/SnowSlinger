extends Node

@onready var label: Label = $ClockLabel
#@onready var timer: Timer = $CountdownTimer
var timer
var remaining_time: int = 360  # Set countdown start time (in seconds)

func _ready():
	update_label()
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)  # Connect signal
	timer.start()  # Start the timer

func _on_timer_timeout():
	remaining_time -= 1
	update_label()
	
	if remaining_time <= 0:
		print("Time's up!")
		timer.stop()  # Stop the timer when it reaches 0
	else:
		timer.start()  # Restart the timer to continue countdown

func update_label():
	print(remaining_time)
	#label.text = str(remaining_time)  # Update UI Label
