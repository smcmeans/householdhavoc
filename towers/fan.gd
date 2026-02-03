extends ProjectileTower

@export var projectile_push_time: float = 1

func fire():
	if projectile_scene == null:
		print("No projectile scene assigned.")
		return

	var wind_gust = create_projectile()
	wind_gust.push_time = projectile_push_time

	# Calculate direction based on where the pivot is facing
	wind_gust.direction = Vector2.RIGHT.rotated(pivot.rotation)
	
	# Add to World
	get_tree().root.add_child(wind_gust)

	current_target = null
