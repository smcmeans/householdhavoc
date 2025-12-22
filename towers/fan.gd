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

func update_target():
	# If our current target died or escaped, forget them
	if is_instance_valid(current_target):
		if not current_target.targetable:
			current_target = null
	else:
		current_target = null

	# If we have no target, try to find one from potential targets
	if current_target == null and potential_targets.size() > 0:
		for enemy in potential_targets:
			if enemy.targetable and not enemy.has_status("blown_away"):
				current_target = enemy
				break
