extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var snowball_scene: PackedScene

var camera: Camera3D
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")

var anim_player: AnimationPlayer


#===============[player weapon]===================
const SLINGSHOT = preload("res://Resources/Weapon/Slingshot.tres")
const MELEE = preload("res://Resources/Weapon/Melee.tres")

var current_weapon: Weapon = SLINGSHOT
var current_ammo : int = 0
var can_shoot : bool = true

#=================================================

func _ready():
	anim_player = $Camera3D/CanvasLayer/Control/Hand/AnimationPlayer
	camera = $Camera3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Mouse Look (Controller uses Joystick)
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * GameManager.mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * GameManager.mouse_sensitivity))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

	if event.is_action_pressed("shoot"):
		$GunSystem.shoot()
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			print("G pressed")
			test_gun_equip()
		if event.keycode == KEY_3:
			print("T pressed")
			test_melee_equip()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta  # Apply gravity
		
	# Controller Look (Right Stick)
	var look_x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var look_y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if abs(look_x) > 0.1 or abs(look_y) > 0.1:
		rotate_y(deg_to_rad(-look_x * GameManager.mouse_sensitivity * 5))
		camera.rotate_x(deg_to_rad(-look_y * GameManager.mouse_sensitivity * 5))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

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
	

func _loop_bgm():
	$AudioStreamPlayer3D.play()

func test_gun_equip():
	current_weapon = SLINGSHOT
	$Camera3D/CanvasLayer/Control/Hand.texture = current_weapon.sprite
func test_melee_equip():
	current_weapon = MELEE
	$Camera3D/CanvasLayer/Control/Hand.texture = current_weapon.sprite
