extends CharacterBody3D

@export var mouse_sensitivity: float = 0.1
@export var speed: float = 4.0
@export var floating_penalty : float = 1
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
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
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
		if event.keycode == KEY_ESCAPE:
			# show cursor
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta  # Apply gravity

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity  # Jumping

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		if velocity.y != 0:
			velocity.x = direction.x * speed * floating_penalty 
			velocity.z = direction.z * speed * floating_penalty
		else:
			velocity.x = direction.x * speed 
			velocity.z = direction.z * speed
	else:
		if velocity.y != 0:
			#floating
			velocity.x = move_toward(velocity.x, 0, delta * 3)
			velocity.z = move_toward(velocity.z, 0, delta * 3)
		else:
			velocity.x = 0
			velocity.z = 0
			
	move_and_slide()
	

func test_gun_equip():
	current_weapon = SLINGSHOT
	$Camera3D/CanvasLayer/Control/Hand.texture = current_weapon.sprite
func test_melee_equip():
	current_weapon = MELEE
	$Camera3D/CanvasLayer/Control/Hand.texture = current_weapon.sprite
