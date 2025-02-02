extends Node3D

@export var speed: float = 15.0
@export var maxRange: float = 100 # Max range snowball can travel

var initPos: Vector3

func _ready():
	initPos = position

func _process(delta):
	if abs(initPos.z - global_position.z) > maxRange:
		queue_free()
	global_translate(transform.basis.z * -speed * delta)

func _on_Hit(body: Node3D):
	if !body.is_in_group("Player"):
		print("Hit")
		queue_free()
