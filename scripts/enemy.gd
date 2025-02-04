extends CharacterBody3D

@export var player: Node3D
@export var speed: float = 3.0
@export var accel: float = 5.0
@export var sprite: Texture2D
@export var health: float = 100

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sprite3d: Sprite3D = $Sprite3D

func _ready():
	sprite3d.texture = sprite

func _physics_process(delta):
	navigation_agent.target_position = player.global_transform.origin
	var next_position = navigation_agent.get_next_path_position()
	
	var direction = (next_position - global_transform.origin).normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)

	move_and_slide()
