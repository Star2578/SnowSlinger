extends Node

@export var parent : CharacterBody3D
@onready var weapon_cooldown: Timer = $WeaponCooldown
@onready var melee_raycast = $"../Camera3D/Bullet_RayCast3D"  # Adjust path to RayCast3D
@onready var fire_sound_player = $"../Camera3D/FireSoundPlayer3D"
@onready var reload_sound_player = $"../Camera3D/ReloadSoundPlayer3D"
				
var current_weapon : Weapon
var current_ammo : int

func reload():
	current_weapon = parent.current_weapon
	if parent.is_reload:
		return
	if current_weapon.type == Weapon.WeaponType.MELEE:
		return
	if parent.current_ammo == current_weapon.mag_size:
		return
	if parent.stored_ammo <= 0:
		return
		
	if parent.is_zoom:
		toggle_zoom()
		
	if current_weapon.reload_sound:
		reload_sound_player.stream = current_weapon.reload_sound
		reload_sound_player.play()
	
	parent.is_reload = true
	#parent.anim_player.speed_scale = current_weapon.reload_time/
	parent.anim_player.play("Reload")

	await parent.anim_player.animation_finished
	parent.anim_player.speed_scale = 1
	print("reloaded!!")
	
	var remain = parent.current_ammo
	parent.current_ammo = min(parent.current_ammo + parent.stored_ammo , current_weapon.mag_size)
	
	var ammo_reloaded = parent.current_ammo - remain
	parent.stored_ammo = max(0, parent.stored_ammo - ammo_reloaded )
	
	parent.is_reload = false

func shoot():
	current_weapon = parent.current_weapon
	
	if (parent.current_ammo <= 0) and (current_weapon.type != Weapon.WeaponType.MELEE):
		print("Out of ammo!")
		reload()
		return
	elif (not parent.can_shoot) or (parent.is_reload):
		return
	else:
		if not parent.snowball_scene:
			return
		
		if current_weapon.firing_sound.size() > 0:
			fire_sound_player.stream = current_weapon.firing_sound.pick_random()
			fire_sound_player.play()
		
		# cooldown by firerate (bullet/sec)
		parent.can_shoot = false
		weapon_cooldown.start(1/current_weapon.fire_rate)
		weapon_cooldown.timeout.connect(func(): parent.can_shoot = true)
		
		parent.anim_player.play("shoot")
		
		if current_weapon.type != Weapon.WeaponType.MELEE:
			GameManager.ammo_used += 1
			parent.current_ammo = max(0,parent.current_ammo - 1)
		
		match current_weapon.type:
			Weapon.WeaponType.MELEE:
				melee_raycast.target_position = Vector3(0,0,-current_weapon.bullet_range)
				melee_raycast.force_raycast_update()
				var hit_target = melee_raycast.get_collider()
				var collision_point = melee_raycast.get_collision_point()
				var collision_normal = melee_raycast.get_collision_normal()
				#If the bullet hit an object, get it's data
				if hit_target != null and hit_target.is_in_group("Enemy"):
					hit_target.take_damage(current_weapon.damage)
					print("Target hit (melee)")
			
			Weapon.WeaponType.SHOTGUN:
				for n in current_weapon.bullet_amount:
					initialize_snowball(current_weapon)
			_:
				#every other [single projectile gun]
				initialize_snowball(current_weapon)

func initialize_snowball(weapon:Weapon):
	var snowball = parent.snowball_scene.instantiate()
	parent.get_parent().add_child(snowball)
	# Set position to player's gun or camera
	var cam_gb_transform = $"../Camera3D".global_transform
	
	snowball.initPos = $"../Camera3D".global_position
	snowball.global_transform.origin = snowball.global_transform.origin + ( - cam_gb_transform.basis.z * 0.5) #spawn infront of player
	snowball.speed = weapon.bullet_speed
	snowball.maxRange = weapon.bullet_range
	snowball.global_transform = cam_gb_transform
	snowball.damage = weapon.damage
	snowball.knockback_str = weapon.knockback_strength
	
	if weapon.spread > 0:
		# bullet spread
		var rng = RandomNumberGenerator.new()
		var xrand = rng.randf_range(-weapon.spread, weapon.spread)
		var yrand = rng.randf_range(-weapon.spread, weapon.spread)
		var xdegrand
		var ydegrand
		
		if min(xrand , 0) == xrand:
			xdegrand = rng.randf_range(-weapon.spread, 0)
		else:
			xdegrand = rng.randf_range(0, weapon.spread)
		if min(yrand , 0) == xrand:
			ydegrand = rng.randf_range(-weapon.spread, 0)
		else:
			ydegrand = rng.randf_range(0, weapon.spread)
		var spreadx = ( cam_gb_transform.basis.x * xrand)
		var spready = ( cam_gb_transform.basis.y * yrand)
		
		#snowball.global_transform.origin = 	 cam_gb_transform.origin + ( - cam_gb_transform.basis.z * 0.5) + spreadx + spready
		snowball.global_transform.origin += spreadx + spready
		snowball.global_transform.basis = snowball.global_transform.basis.rotated(cam_gb_transform.basis.y,PI/6 * xdegrand)
		snowball.global_transform.basis = snowball.global_transform.basis.rotated(cam_gb_transform.basis.x,PI/6 * ydegrand)
	return snowball
	
func perform_swap_action(new_weapon:Weapon , from_floor:bool = false):
	if parent.current_weapon.type == new_weapon.type and not from_floor: 
		return
	if parent.is_reload or parent.is_equip:
		return	
	if parent.is_zoom:
		#cancel zoom when swap
		toggle_zoom()
		
	parent.is_equip = true
	parent.anim_player.stop()
	weapon_cooldown.stop()
	
	#prevent quick-swap
	parent.can_shoot = false
	weapon_cooldown.start(0.6)
	weapon_cooldown.timeout.connect(func(): parent.can_shoot = true)
	
	parent.anim_player.play("Equip")
	
	if from_floor:
		parent.current_ammo = 0 #reset ammo on pick up new gun
	
	#change weapon & sprite
	parent.current_weapon = new_weapon 
	current_weapon = parent.current_weapon
	$"../Camera3D/CanvasLayer/Control/Hand".texture = current_weapon.sprite #new sprite
	
	parent.is_equip = false
	

func perform_right_click():
	if parent.is_reload:
		return
	if parent.current_weapon.type == Weapon.WeaponType.SNIPER:
		toggle_zoom()
		
func toggle_zoom():
	current_weapon = parent.current_weapon
	var camera = $"../Camera3D"
	if not parent.is_zoom:
		camera.fov /= current_weapon.scope_mult
	else:
		camera.fov = 75
	parent.is_zoom = not parent.is_zoom
