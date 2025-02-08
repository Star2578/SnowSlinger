extends BaseItem
class_name Ammo

func _on_pick(body):
	# TODO : Increase player ammo
	body.stored_ammo += 1
	print("Ammo +1")
