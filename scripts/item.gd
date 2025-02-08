extends Node3D

@export var item: BaseItem
@onready var sprite3d: Sprite3D = $Sprite3D

func _ready():
	if item and sprite3d:
		sprite3d.texture = item.sprite

func _on_pick(body: Node3D):
	if body.is_in_group("Player"):
		item._on_pick(body)
		queue_free()
