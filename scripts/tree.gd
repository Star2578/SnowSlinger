extends Node3D

var is_harvest: bool = false
var is_finished: bool = false
var progress: float = 0.0
var player_in_range: bool = false

@export var harvest_time: float = 2.0  # How long to hold F

@onready var canvas_layer = $CanvasLayer
@onready var progress_bar = $CanvasLayer/Control/Progress

func _ready():
	$CanvasLayer.visible = false
	progress = 0
	progress_bar.scale.x = 0

func _physics_process(delta):
	if player_in_range and !is_finished:
		if _player_is_looking_at_me():
			canvas_layer.visible = true
			if Input.is_action_pressed("interact"):
				start_harvest(delta)
		else:
			progress = 0
			canvas_layer.visible = false  # Hide if not looking
	else:
		progress = 0
		canvas_layer.visible = false  # Hide if out of range

func start_harvest(delta):
	$CanvasLayer/Control.visible = true
	is_harvest = true
	progress += delta / harvest_time
	progress_bar.scale.x = progress

	if progress >= 1.0:
		_finished_harvest()

func _finished_harvest():
	$CanvasLayer/Control.visible = false
	GameManager.campfire_energy = 100
	is_finished = true
	is_harvest = false
	visible = false
	$DestroyedSound.play()

func _player_is_looking_at_me() -> bool:
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("No player")
		return false

	var direction_to_tree = (global_transform.origin - player.global_transform.origin).normalized()
	var player_forward = -player.camera.global_transform.basis.z  # Camera forward direction

	return direction_to_tree.dot(player_forward) > 0.5  # Adjust for detection accuracy

func _on_area_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		print("Player in")

func _on_area_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		print("Player out")

func _clean_node():
	queue_free()
