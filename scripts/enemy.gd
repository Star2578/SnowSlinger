extends CharacterBody3D


var gravity: float = ProjectSettings.get("physics/3d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta  # Apply gravity
		
	move_and_slide()
