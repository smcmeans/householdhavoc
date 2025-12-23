extends Projectile

var hanger_trapped_duration: float = 0.2
var bouncy_hangers: bool = false
var multiplicative_damage: bool = false

var hit_enemies: Array = []

func _physics_process(delta):
	super(delta) 
	
	# Add spinning
	sprite.rotation += 10.0 * delta

func apply_effect(enemy):
	# Deal damage
	if multiplicative_damage:
		enemy.take_damage(damage * piercing)
	else:
		enemy.take_damage(damage)
	
	if bouncy_hangers:
		# Find nearest enemy within 100 pixels
		hit_enemies.append(enemy)
		var nearest_enemy = null
		var nearest_distance = 200.0
		for other_enemy in get_tree().get_nodes_in_group("enemies"):
			if other_enemy not in hit_enemies:
				var dist = position.distance_to(other_enemy.position)
				if dist < nearest_distance:
					nearest_distance = dist
					nearest_enemy = other_enemy
		if nearest_enemy != null:
			# Redirect projectile to nearest enemy
			direction = (get_predicted_target_position(nearest_enemy) - position).normalized()

	enemy.apply_status("hanger_trapped", hanger_trapped_duration)

func get_predicted_target_position(current_target) -> Vector2:
	var path_follow = current_target
	
	# Safety Check: If for some reason we aren't on a path, fall back to current pos
	if not path_follow:
		return current_target.global_position

	var path_2d = path_follow.get_parent() # The actual Path2D node
	if not (path_2d is Path2D):
		return current_target.global_position
		
	# --- STEP 1: Initial Guess ---
	# How far is the enemy right now?
	var dist_to_enemy = global_position.distance_to(current_target.global_position)
	var time_to_hit = dist_to_enemy / speed
	
	# Predict how much 'progress' (pixels) they will travel in that time
	var future_distance = current_target.move_speed * time_to_hit
	var predicted_progress = path_follow.progress + future_distance
	
	# --- STEP 2: Refine the Guess (Iterative) ---
	# Get the coordinate of that guess
	var predicted_pos_local = path_2d.curve.sample_baked(predicted_progress, true)
	var predicted_pos_global = path_2d.to_global(predicted_pos_local)
	
	# Re-calculate distance to this NEW spot
	var new_dist = global_position.distance_to(predicted_pos_global)
	var new_time = new_dist / speed
	
	# Re-calculate progress with the better time
	var refined_distance = current_target.move_speed * new_time
	var final_progress = path_follow.progress + refined_distance
	
	# --- STEP 3: Get Final Position ---
	var final_pos_local = path_2d.curve.sample_baked(final_progress, true)
	return path_2d.to_global(final_pos_local)
