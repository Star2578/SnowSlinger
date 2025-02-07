extends Node3D

@export var speed: float = 18.0
@export var maxRange: float = 20 # Max range snowball can travel

var initPos: Vector3
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var vy:float = 0.0
var fade_fx: Tween

func _ready():
	pass
func _process(delta):
	vy += gravity * delta
	if initPos.distance_to(position) > maxRange:
		fade_fx = get_tree().create_tween()
		fade_fx.tween_property($Sprite3D, "modulate:a", 0, 0.03)
	global_translate(transform.basis.z * -speed * delta)
	global_translate(transform.basis.y * -vy * delta)
func _on_Hit(body: Node3D):
	if !body.is_in_group("Player"):
		if fade_fx != null:
			fade_fx.kill()
		queue_free()
