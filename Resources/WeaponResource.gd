extends Resource
class_name Weapon

enum WeaponType {
	MELEE,
	BASIC_GUN,
	SUBMACHINEGUN,
	SHOTGUN,
	SNIPER
}

@export var type : WeaponType = WeaponType.BASIC_GUN
@export var automatic : bool = false
@export var weapon_name: String

@export_category("Sprite")
@export var sprite: CompressedTexture2D

@export_category("Sound effects")
@export var firing_sound : Array[AudioStream]
@export var reload_sound : AudioStream
@export var dry_fire_sound : AudioStream

@export_category("Weapown Stats")
@export var pierce : bool
@export var damage : int
@export var mag_size : int #number of ammo loaded in gun
@export var spread : float = 0
@export var bullet_amount : int = 1
@export var fire_rate : float = 0.25
@export var bullet_speed : float
@export var bullet_range:float
@export var scope_mult: float = 1
@export var reload_time: float = 1
@export var knockback_strength: float = 10
