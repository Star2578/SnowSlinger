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
const MELEE = preload("res://Resources/Weapon/Melee.tres")
const SHOTGUN = preload("res://Resources/Weapon/Shotgun.tres")
const SLINGSHOT = preload("res://Resources/Weapon/Slingshot.tres")
const SNIPER = preload("res://Resources/Weapon/Sniper.tres")
const SUB_SNOWGUN = preload("res://Resources/Weapon/SubSnowgun.tres")

var current_weapon: Weapon = SLINGSHOT
var current_slot : int = 1
var stored_ammo : int = 90
var current_ammo : int = current_weapon.mag_size
var can_shoot : bool = true
var shootbutton_down : bool = false
var is_reload: bool = false
var is_zoom : bool = false
var is_equip : bool = false
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
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				hotbar_swapto(1)
			KEY_2:
				pass
			KEY_3:
				hotbar_swapto(3)
			KEY_R:
				$GunSystem.reload()
				
		if event.keycode == KEY_Y:
			print(current_ammo,"/",stored_ammo)
		if event.keycode == KEY_O:
			# show cursor
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):

	#auto vs semi-auto
	if Input.is_action_just_pressed("shoot") and !current_weapon.automatic:
		$GunSystem.shoot()
		#Automatic
	elif Input.is_action_pressed("shoot") and current_weapon.automatic:
		$GunSystem.shoot()
	

	if Input.is_action_just_pressed("right_action"):
		$GunSystem.perform_right_click()
	
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
	
func _loop_bgm():
	$AudioStreamPlayer3D.play()

func hotbar_swapto(n : int):
	if n == 1:
		$GunSystem.perform_swap_action(SLINGSHOT)
	elif n == 2:
		pass
	elif n == 3:
		$GunSystem.perform_swap_action(MELEE)
