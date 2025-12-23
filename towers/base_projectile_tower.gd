extends Tower
class_name ProjectileTower

@export var projectile_scene: PackedScene 
@export var projectile_speed: float = 400.0
@export var projectile_piercing: int = 1

@onready var pivot = $Pivot
@onready var spawn_point = $Pivot/SpawnPoint

func _physics_process(delta):
	# Rotate towards target if we have one
	if current_target != null:
		var aim_point = get_predicted_target_position()
		pivot.look_at(aim_point)
		
	super(delta)

func is_turret_aimed() -> bool:
	if current_target == null:
		return false

	# Calculate angle difference
	var target_dir = global_position.direction_to(get_predicted_target_position())
	var target_angle = target_dir.angle()
	
	var current_angle = pivot.rotation
	
	# Check if within threshold
	if abs(angle_difference(current_angle, target_angle)) < 0.1:
		return true
	
	
	return false

func create_projectile():
	var projectile = projectile_scene.instantiate()
	
	# Set projectile properties
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
		
	# Find the distance to the enemy
	var dist_to_enemy = global_position.distance_to(current_target.global_position)
	var time_to_hit = dist_to_enemy / projectile_speed
	
	# Predict how much progress they will travel in that time
	var future_distance = current_target.move_speed * time_to_hit
	var predicted_progress = path_follow.progress + future_distance
	
	# Get the coordinate of that guess
	var predicted_pos_local = path_2d.curve.sample_baked(predicted_progress, true)
	var predicted_pos_global = path_2d.to_global(predicted_pos_local)
	
	# Re-calculate distance to this NEW spot
	var new_dist = global_position.distance_to(predicted_pos_global)
	var new_time = new_dist / projectile_speed
	
	# Re-calculate progress with the better time
	var refined_distance = current_target.move_speed * new_time
	var final_progress = path_follow.progress + refined_distance
	
	# Get Final Position
	var final_pos_local = path_2d.curve.sample_baked(final_progress, true)
	return path_2d.to_global(final_pos_local)

func start_recoil_shake():
	# 1. Get the sprite (Make sure this path is correct for your scene!)
	var sprite = $Sprite2D
	
	# 2. Create a Tween
	var tween = create_tween()
	
	# 3. Define the Shake (Kick back -> Return)
	# Since the sprite is inside the Pivot, moving X negative kicks it "backwards"
	# regardless of which way the tower is rotating.
	
	# Step A: Kick back 10 pixels instantly (0.05 seconds)
	tween.tween_property(sprite, "position:x", -5.0, 0.02)
	
	# Step B: Return to center (0.0) slightly slower (0.1 seconds)
	tween.tween_property(sprite, "position:x", 0.0, 0.1)
