extends ProjectileTower

func fire():
	if projectile_scene == null:
		print("Error: No projectile scene assigned to Closet Tower!")
		return
	
	var hanger = create_projectile()
	
	# Calculate direction based on where the pivot is facing
	hanger.direction = Vector2.RIGHT.rotated(pivot.rotation)
	#hanger.rotation = pivot.rotation # Rotate the sprite too
	
	# D. Add to World (CRITICAL STEP)
	get_tree().root.add_child(hanger)