extends CharacterBody3D

@export var mouse_sensitivity: float = 0.1
@export var speed: float = 4.0
@export var floating_penalty : float = 0.8
@export var jump_velocity: float = 4.5
@export var snowball_scene: PackedScene
@export var health: float = 200

@onready var hand: Sprite2D = $Camera3D/CanvasLayer/Control/Hand

var camera: Camera3D
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var anim_player: AnimationPlayer
var is_cold: bool = false
#===============[player weapon]===================
const MELEE = preload("res://Resources/Weapon/Melee.tres")
const SHOTGUN = preload("res://Resources/Weapon/Shotgun.tres")
const SLINGSHOT = preload("res://Resources/Weapon/Slingshot.tres")
const SNIPER = preload("res://Resources/Weapon/Sniper.tres")
const SUB_SNOWGUN = preload("res://Resources/Weapon/SubSnowgun.tres")

var slot1 : Weapon = SHOTGUN
var slot2 : Weapon = MELEE
var current_weapon: Weapon = slot1

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
	hand.texture = current_weapon.sprite
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
		if event.keycode == KEY_H:
			GameManager.on_win()
		if event.keycode == KEY_O:
			# show cursor
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	_update_gui()

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

func _update_gui():
	$Camera3D/CanvasLayer/Control/Ammo/Count.text = str(current_ammo,"/",stored_ammo)
	$Camera3D/CanvasLayer/Control/Heat/Heatbar.scale.x = float(health / 200)
	$Camera3D/CanvasLayer/Control/Heat/WARNING.visible = is_cold

func heal(amount: float):
	print("Heal ", amount)
	health = min(200, health + amount)

func take_damage(amount: float):
	print("Took ", amount, " dmg")
	health = max(0, health - amount)
	if health <= 0:
		print("GAME OVER!")
		GameManager.on_gameover()

func hotbar_swapto(n : int):
	if n == 1:
		$GunSystem.perform_swap_action(slot1)
	elif n == 2:
		pass
	elif n == 3:
		$GunSystem.perform_swap_action(slot2)
