extends BaseItem
class_name Ammo

func _on_pick(body):
	# TODO : Increase player ammo
	body.stored_ammo += GameManager.weapon_pri.mag_size
