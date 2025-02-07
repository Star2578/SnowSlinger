extends Node

@export var parent : CharacterBody3D
@onready var weapon_cooldown: Timer = $WeaponCooldown
@onready var melee_raycast = $"../Camera3D/Bullet_RayCast3D"  # Adjust path to RayCast3D
				
var current_weapon : Weapon
var current_ammo : int

func reload():
	current_weapon = parent.current_weapon
	
	if current_weapon.type == Weapon.WeaponType.MELEE:
		return
	if parent.current_ammo == current_weapon.mag_size:
		return
	if parent.stored_ammo <= 0:
		return
		
	if parent.is_zoom:
		toggle_zoom()
	
	parent.is_reload = true
	parent.anim_player.play("Reload")

	await parent.anim_player.animation_finished
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
		return
	elif (not parent.can_shoot) or (parent.is_reload):
		return
	else:
		if not parent.snowball_scene:
			return
		
		# cooldown by firerate (bullet/sec)
		parent.can_shoot = false
		weapon_cooldown.start(1/current_weapon.fire_rate)
		weapon_cooldown.timeout.connect(func(): parent.can_shoot = true)
		
		parent.anim_player.play("shoot")
		
		parent.current_ammo = max(0,parent.current_ammo - current_weapon.bullet_amount)
		
		match current_weapon.type:
			Weapon.WeaponType.MELEE:
				melee_raycast.target_position = Vector3(0,0,-current_weapon.bullet_range)
				melee_raycast.force_raycast_update()
				var hit_target = melee_raycast.get_collider()
				var collision_point = melee_raycast.get_collision_point()
				var collision_normal = melee_raycast.get_collision_normal()
				#If the bullet hit an object, get it's data
				if hit_target != null: 
					var valid_bullet : Dictionary = {
						"hit_target" : hit_target,
							"collision_point" : collision_point,
						"collision_normal" : collision_normal,
					}
					print("HIT: ", valid_bullet)
			
			Weapon.WeaponType.SHOTGUN:
				for n in current_weapon.bullet_amount:
					var snowball = parent.snowball_scene.instantiate()
					parent.get_parent().add_child(snowball)
					# Set position to player's gun or camera
					#snowball.position = parent.position
					snowball.speed = current_weapon.bullet_speed
					snowball.maxRange = current_weapon.bullet_range
					snowball.global_transform = $"../Camera3D".global_transform
					
					var cam_gb_transform = $"../Camera3D".global_transform
					
					# bullet spread
					var rng = RandomNumberGenerator.new()
					var xrand = rng.randf_range(-current_weapon.spread, current_weapon.spread)
					var yrand = rng.randf_range(-current_weapon.spread, current_weapon.spread)	
					#var xdegrand = rng.randf_range(-current_weapon.spread, current_weapon.spread)
					#var ydegrand = rng.randf_range(-current_weapon.spread, current_weapon.spread)

					var xdegrand
					var ydegrand
					if min(xrand , 0) == xrand:
						xdegrand = rng.randf_range(-current_weapon.spread, 0)
					else:
						xdegrand = rng.randf_range(0, current_weapon.spread)
					if min(yrand , 0) == xrand:
						ydegrand = rng.randf_range(-current_weapon.spread, 0)
					else:
						ydegrand = rng.randf_range(0, current_weapon.spread)
					
					
						
					var spreadx = ( cam_gb_transform.basis.x * xrand)
					var spready = ( cam_gb_transform.basis.y * yrand)
					
					snowball.initPos = $"../Camera3D".global_position
					snowball.global_transform.origin = 	 cam_gb_transform.origin + ( - cam_gb_transform.basis.z * 0.5) + spreadx + spready
					snowball.global_transform.basis = snowball.global_transform.basis.rotated(cam_gb_transform.basis.y,PI/6 * xdegrand)
					snowball.global_transform.basis = snowball.global_transform.basis.rotated(cam_gb_transform.basis.x,PI/6 * ydegrand)
			
			_:
				#every other [single projectile gun]
				var snowball = parent.snowball_scene.instantiate()
				parent.get_parent().add_child(snowball)
				# Set position to player's gun or camera
				#snowball.position = parent.position
				snowball.speed = current_weapon.bullet_speed
				snowball.global_transform = $"../Camera3D".global_transform
				# give some distance between camara
				snowball.initPos = $"../Camera3D".global_position
				snowball.global_transform.origin = 	 $"../Camera3D".global_transform.origin + ( - $"../Camera3D".global_transform.basis.z * 0.5)
		
		
func perform_swap_action(weapon:Weapon):
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
	
	#change weapon & sprite
	parent.current_weapon = weapon 
	current_weapon = parent.current_weapon
	$"../Camera3D/CanvasLayer/Control/Hand".texture = current_weapon.sprite #new sprite
	
	parent.is_equip = false
	
func change_gun(new_weapon : Weapon):
	perform_swap_action(new_weapon)
	if new_weapon.type != Weapon.WeaponType.MELEE:
		parent.current_ammo = 0 #reset ammo on pick up new gun

func perform_left_click():
	if parent.is_reload:
		return
	if parent.current_weapon.type == Weapon.WeaponType.SNIPER:
		toggle_zoom()
		
func toggle_zoom():
	var camera = $"../Camera3D"
	if not parent.is_zoom:
		camera.fov /= current_weapon.scope_mult
	else:
		camera.fov = 75
	parent.is_zoom = not parent.is_zoom
