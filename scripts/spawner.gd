extends Node3D

@export var enemy_scenes: Array[PackedScene]  # List of enemy types
@export var player: Node3D  # Assign the player
@export var spawn_area: Node3D  # Assign a PlaneMesh node (for spawn area)
@export var spawn_interval: float = 3.0  # Time between spawns
@export var max_enemies: int = 20  # Limit number of enemies

func _ready():
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.connect("timeout", _on_spawn_timer_timeout)
	add_child(timer)

func _on_spawn_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	if not is_inside_tree():
		await ready  # Wait until the node is fully inside the scene tree

	var random_enemy_scene = enemy_scenes.pick_random()  # Pick a random enemy type
	var enemy = random_enemy_scene.instantiate()
	
	if enemy.has_method("set_target"):
		enemy.set_target(player)  # Assign the player as the target

	get_parent().add_child.call_deferred(enemy)
	enemy.global_transform.origin = get_random_spawn_position()

func get_random_spawn_position() -> Vector3:
	var area_size = spawn_area.mesh.size  # Get size of PlaneMesh
	var offset = 10
	var random_x = randf_range(-(area_size.x - offset) / 2, (area_size.x - offset) / 2)
	var random_z = randf_range(-(area_size.y - offset) / 2, (area_size.y - offset) / 2)
	var spawn_position = spawn_area.global_transform.origin + Vector3(random_x, 1.0, random_z)
	return spawn_position
