extends BaseItem
class_name Wood

func _on_pick(body):
	GameManager.campfire_energy = min(GameManager.campfire_energy + 10, GameManager.campfire_energy_max)
