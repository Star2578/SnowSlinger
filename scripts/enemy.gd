extends CharacterBody3D

@export var player: Node3D
@export var sprite: Texture2D
@export var speed: float = 3.0
@export var accel: float = 5.0
@export var health: float = 100
@export var attack_speed: float = 0.5
@export var damage: int = 2
@export var knockback_strength: float = 3.0

@export var item_drops: Array[PackedScene]
@export var drop_chance: float = 0.25

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sprite3d: Sprite3D = $Sprite3D
@onready var attack_interval: Timer = $AttackInterval

var can_attack : bool = true
var is_dead: bool = false

func _ready():
	sprite3d.texture = sprite
	sprite3d.visible = true
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)
	attack_interval.timeout.connect(_reset_attack)

func _physics_process(delta):
	if health > 0:
		navigation_agent.target_position = player.global_transform.origin
		var next_position = navigation_agent.get_next_path_position()
		
		var direction = (next_position - global_transform.origin).normalized()
		velocity = velocity.lerp(direction * speed, accel * delta)
		
		if global_transform.origin.distance_to(player.global_transform.origin) < 1.5:
			attack(player)
		move_and_slide()

func attack(player):
	if not can_attack:
		return
	can_attack = false
	
	if player.has_method("take_damage"):  
		player.take_damage(damage)
	attack_interval.start(1/attack_speed)

func _reset_attack():
	can_attack = true

func take_damage(damage):
	flash_black()
	
	health = max(0,health - damage)
	velocity = Vector3.UP * 2
	if health <= 0:
		ondeath()
	print("Hp : " , health)

func flash_black():
	$Sprite3D.modulate = Color.BLACK  # Turn black
	
	await get_tree().create_timer(0.2).timeout  # Wait 0.2 seconds
	$Sprite3D.modulate = Color.WHITE  # Restore original color

func set_target(target: Node3D):
	player = target

func ondeath():
	if is_dead:
		return
	
	is_dead = true
	$Sprite3D.modulate = "#000000"
	var dtween = get_tree().create_tween()
	dtween.tween_property($Sprite3D, "modulate:a", 0, 0.5)
	
	await dtween.finished
	
	GameManager.kill_count += 1
	drop_item()
	queue_free()

func drop_item():
	if item_drops.is_empty():
		return  # No items to drop

	if randf() < drop_chance:
		var random_item = item_drops.pick_random()
		var item_instance = random_item.instantiate()
		get_tree().root.add_child.call_deferred(item_instance)
		call_deferred("_set_item_position", item_instance)

		print("Dropped item:", item_instance.name)
	else:
		print("No item dropped this time!")

func _set_item_position(item_instance):
	item_instance.global_transform.origin = global_transform.origin
	queue_free()
