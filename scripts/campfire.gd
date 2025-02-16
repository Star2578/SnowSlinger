extends Node3D

@export var player: Node3D
@export var warm_range: float = 20
@export var cold_damage: int = 10  # Damage per tick
@export var heal_amount: int = 2.5  # Healing per tick
@export var effect_time: float = 3.0  # Must stay/leave for X seconds before effect

var time_away = 0.0
var time_near = 0.0

func _ready():
	$Sprite3D/AnimationPlayer.play("idle")

func _physics_process(delta):
	var distance = position.distance_to(player.position)
	
	if distance > warm_range:
		player.is_cold = true;
		time_near = 0  # Reset healing timer
		time_away += delta  # Increase cold timer

		if time_away >= effect_time:
			player.take_damage(cold_damage)  # Call player's damage function
			time_away = 0  # Reset timer after applying damage

		#print("COLD: ", time_away, "s")
	
	else:
		player.is_cold = false;
		time_away = 0  # Reset cold timer
		time_near += delta  # Increase healing timer

		if time_near >= 0.16:
			player.heal(heal_amount)  # Call player's heal function
			time_near = 0  # Reset timer after healing

		#print("WARM: ", time_near, "s")
