extends Tower
class_name ProjectileTower

@export var projectile_scene: PackedScene 
@export var projectile_speed: float = 400.0
@export var projectile_piercing: int = 1

@onready var pivot = $Pivot
@onready var spawn_point = $Pivot/SpawnPoint

func _physics_process(delta):
	# 1. HANDLE ROTATION
	if current_target != null:
		var aim_point = get_predicted_target_position()
		pivot.look_at(aim_point)
		
	# 2. RUN BASE LOGIC (Firing timers, target switching)
	# 'super' calls the _physics_process from BaseTower.gd
	super(delta)

func is_turret_aimed() -> bool:
	if current_target == null:
		return false

	# 1. Calculate the angle we WANT to be at
	var target_dir = global_position.direction_to(get_predicted_target_position())
	var target_angle = target_dir.angle()
	
	# 2. Get our CURRENT angle (The Pivot's rotation)
	var current_angle = pivot.rotation
	
	# 3. Compare them!
	# If the difference is small (e.g., less than 0.1 radians / ~5 degrees), we are aimed.
	# We use 'angle_difference' to handle the jump from 360 to 0 degrees smoothly.
	if abs(angle_difference(current_angle, target_angle)) < 0.1:
		return true
	
	# Optional: If we are close but not perfect, snap to it so we don't miss by 1 frame
	# pivot.look_at(current_target.global_position)
	
	return false

func create_projectile():
	var projectile = projectile_scene.instantiate()
	
	# B. Setup stats (Use the Tower's damage variable)
	projectile.damage = damage 
	projectile.speed = projectile_speed
	projectile.piercing = projectile_piercing

	projectile.global_position = spawn_point.global_position

	return projectile

func get_predicted_target_position() -> Vector2:
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
	var time_to_hit = dist_to_enemy / projectile_speed
	
	# Predict how much 'progress' (pixels) they will travel in that time
	var future_distance = current_target.move_speed * time_to_hit
	var predicted_progress = path_follow.progress + future_distance
	
	# --- STEP 2: Refine the Guess (Iterative) ---
	# Get the coordinate of that guess
	var predicted_pos_local = path_2d.curve.sample_baked(predicted_progress, true)
	var predicted_pos_global = path_2d.to_global(predicted_pos_local)
	
	# Re-calculate distance to this NEW spot
	var new_dist = global_position.distance_to(predicted_pos_global)
	var new_time = new_dist / projectile_speed
	
	# Re-calculate progress with the better time
	var refined_distance = current_target.move_speed * new_time
	var final_progress = path_follow.progress + refined_distance
	
	# --- STEP 3: Get Final Position ---
	var final_pos_local = path_2d.curve.sample_baked(final_progress, true)
	return path_2d.to_global(final_pos_local)
