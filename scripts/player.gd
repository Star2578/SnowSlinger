extends CharacterBody3D

@export var mouse_sensitivity: float = 0.1
@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var snowball_scene: PackedScene

var camera: Camera3D
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")

var anim_player: AnimationPlayer

func _ready():
	anim_player = $Camera3D/CanvasLayer/Control/Hand/AnimationPlayer
	camera = $Camera3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	if event.is_action_pressed("shoot"):
		shoot_snowball()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta  # Apply gravity

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity  # Jumping

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func shoot_snowball():
	if not snowball_scene:
		return
	
	anim_player.play("shoot")
	
	var snowball = snowball_scene.instantiate()
	get_parent().add_child(snowball)
	
	# Set position to player's gun or camera
	snowball.global_transform = $Camera3D.global_transform
