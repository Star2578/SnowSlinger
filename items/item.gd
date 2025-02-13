extends Node3D

@export var item_data: BaseItem

func _ready():
	$Sprite3D.texture = item_data.sprite

func _on_item_pickup(body: Node3D):
	if body.is_in_group("Player"):
		item_data._on_pick(body)
		queue_free()
