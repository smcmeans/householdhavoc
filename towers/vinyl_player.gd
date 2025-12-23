extends ProjectileTower

@export var projectile_spin_time: float = 1.0

func fire():
	if projectile_scene == null:
		print("No projectile scene assigned.")
		return

	var vinyl = create_projectile()
	vinyl.spin_time = projectile_spin_time

	# Calculate direction based on where the pivot is facing
	vinyl.direction = Vector2.RIGHT.rotated(pivot.rotation)
	
	# Add to World
	get_tree().root.add_child(vinyl)

	start_recoil_shake()