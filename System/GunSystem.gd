extends Node

@export var parent : CharacterBody3D
@onready var weapon_cooldown: Timer = $WeaponCooldown

var current_weapon : Weapon
var current_ammo : int = 1

func reload():
	if current_weapon.type == Weapon.WeaponType.MELEE:
		pass

func shoot():
	current_weapon = parent.current_weapon
	
	if (current_ammo <= 0):
		print("Out of ammo!")
	elif not parent.can_shoot:
		print("On cooldown!")
	else:
		if not parent.snowball_scene:
			return
		parent.can_shoot = false
		parent.anim_player.play("shoot")
		
		var snowball = parent.snowball_scene.instantiate()
		parent.get_parent().add_child(snowball)
		
		# Set position to player's gun or camera
		snowball.global_transform = $"../Camera3D".global_transform
		print($"../Camera3D".global_transform)
		# some distance between camara
		snowball.global_transform.origin = 	 $"../Camera3D".global_transform.origin + ( - $"../Camera3D".global_transform.basis.z * 0.5)

		# cooldown by firerate (bullet/sec)
		weapon_cooldown.start(1/current_weapon.fire_rate)
		weapon_cooldown.timeout.connect(func(): parent.can_shoot = true)
