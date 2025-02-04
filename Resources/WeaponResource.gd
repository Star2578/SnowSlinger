extends Resource
class_name Weapon

enum WeaponType {
	MELEE,
	BASIC_GUN
}

@export var type : WeaponType = WeaponType.BASIC_GUN
@export var automatic : bool = false

@export_category("Sprite")
@export var sprite: CompressedTexture2D

@export_category("Sound effects")
@export var firing_sound : Array[AudioStream]
@export var reload_sound : AudioStream
@export var dry_fire_sound : AudioStream

@export_category("Weapown Stats")
@export var damage : int
@export var mag_size : int #number of ammo loaded in gun
@export var spread : int = 0
@export var bullet_amount : int = 1
@export var fire_rate : float = 0.25
