extends Resource
class_name BaseItem

@export var sprite: Texture2D
@export var item_name: String

func _on_pick() -> void:
	push_error("Error: _on_pick() not implemented in subclass of Item")
