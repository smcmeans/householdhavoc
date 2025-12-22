extends PathFollow2D
class_name Enemy

@export var move_speed: float = 150.0
@export var max_health: int = 5
@export var money_reward: int = 5

@onready var health_bar = $TextureProgressBar

@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer
var default_color = Color(1, 1, 1, 1)
var is_trapped: bool = false
var targetable: bool = true

var category: String = ""
 
var current_health: int
var last_position
var active_statuses: Dictionary = {}

var speed_mult = 1

# Stores how much time has passed since the last burn tick
# Format: { "burning": 0.5, "poison": 0.2 }
var status_ticks = {}

func _ready():
	current_health = max_health
	
	# SETUP THE BAR
	health_bar.max_value = max_health
	health_bar.value = current_health
	 
	health_bar.visible = false 
	
	loop = false 

	last_position = global_position

	anim_player.speed_scale = move_speed / 150.0

	

func _process(delta: float) -> void:
	if is_trapped:
		# TODO: Add shivering animation or effect
		return
	else:
		if anim_player.current_animation != "walk":
			anim_player.play("walk")
	
	# Flip sprite based on movement direction
	var movement_vector = global_position - last_position
	if abs(movement_vector.x) >= 0.1:
		sprite.flip_h = movement_vector.x < 0
	last_position = global_position

func _physics_process(delta):
	# Do not move if trapped
	if (is_trapped):
		handle_statuses(delta)
		return

	if has_status("blown_away"):
		push_backwards(delta)
		handle_statuses(delta)
		return

	progress += move_speed * delta * speed_mult
	take_damage(status_damage_over_time(delta))
	if progress_ratio >= 1.0:
		escape_house()
	handle_statuses(delta)

func update_speed_mult() -> void:
	speed_mult = 1
	if has_status("damp"):
		speed_mult *= 0.8
	if has_status("frozen"):
		speed_mult = 0
	if has_status("burning"):
		speed_mult *= 1.2
	if has_status("hanger_trapped"):
		speed_mult = 0
	# Adjust animation speed
	anim_player.speed_scale = (move_speed / 150.0) * speed_mult

func status_damage_over_time(delta):
	var damage_to_deal = 0
	
	# --- BURNING LOGIC ---
	if active_statuses.has("burning"):
		
		# 1. Initialize the timer if it doesn't exist yet
		if not status_ticks.has("burning"):
			status_ticks["burning"] = 0.0
			
		# 2. Add time to the bucket
		status_ticks["burning"] += delta
		
		# 3. Check if bucket is full (1.0 second has passed)
		if status_ticks["burning"] >= 1.0:
			damage_to_deal += 1
			status_ticks["burning"] -= 1.0 # Remove 1 second, keep the remainder
			
			# Optional: Add a cool visual effect here!
			# create_burn_particle()

	return damage_to_deal

func set_trapped(trapped: bool):
	is_trapped = trapped
	# Hide the sprite if inside the dryer
	visibility(not trapped)

func take_damage(amount: int):
	if amount <= 0:
		return

	current_health -= amount
	
	# UPDATE THE BAR
	health_bar.value = current_health
	if targetable:
		health_bar.visible = true
	
	if current_health <= 0:
		die()

func die():
	print("Enemy died!")
	GameData.add_money(money_reward)
	queue_free()

func escape_house():
	queue_free()

func handle_statuses(delta):
	# We get the keys first so we can safely remove items while looping
	var current_effects = active_statuses.keys()
	
	for effect in current_effects:
		# Decrease the timer
		active_statuses[effect] -= delta
		
		# If time runs out, remove the status
		if active_statuses[effect] <= 0:
			remove_status(effect)

func apply_status(effect_name: String, duration: float):
	if effect_name == "burning" and has_status("damp"):
		remove_status("damp")

	if effect_name == "damp":
		# Enemies in the "utensil" category are immune to the "damp" status.
		if category == "utensil":
			return
		if has_status("burning"):
			apply_status_helper("dry", 5.0)
			# TODO: Add steam blast
			take_damage(int(active_statuses["burning"]))
			remove_status("burning")
			return
		if has_status("dry"):
			reduce_status_duration("damp", 1.0)
			return
	
	if effect_name == "blown_away":
		reduce_status_duration("damp", 1.0)

	if effect_name == "hanger_trapped" and not category == "clothes":
		return

	apply_status_helper(effect_name, duration)

func apply_status_helper(effect_name: String, duration: float):
	# Add or refresh the status
	active_statuses[effect_name] = duration
	
	# Update visuals immediately
	update_status_visuals()
	# Update speed multiplier
	update_speed_mult()
	print(name + " applied status: " + effect_name)

func remove_status(effect_name: String):
	if has_status(effect_name):
		active_statuses.erase(effect_name)
		update_status_visuals()
		print(name + " removed status: " + effect_name)
	update_speed_mult()

# Helper for Towers to check
func has_status(effect_name: String) -> bool:
	return active_statuses.has(effect_name)

func reduce_status_duration(status_name: String, amount: float):
	if has_status(status_name):
		active_statuses[status_name] -= amount
		# Ensure it doesn't go below 0 instantly if we don't want it to
		if active_statuses[status_name] < 0:
			active_statuses[status_name] = 0
		print(name + " " + status_name + " reduced by " + str(amount))

# Handle Color Mixing (Priorities)
func update_status_visuals():
	# Reset to normal first
	sprite.modulate = default_color
	
	# Check priorities (Last one applied wins, or define a hierarchy)
	if has_status("frozen"):
		sprite.modulate = Color(0.5, 1, 1) # Cyan
	elif has_status("damp"):
		sprite.modulate = Color(0.7, 0.7, 1.5) # Blue tint
	elif has_status("burning"):
		sprite.modulate = Color(1, 0.5, 0.5) # Red tint

func visibility(able_to_be_seen: bool):
	if has_node("Sprite2D"):
		sprite.visible = able_to_be_seen
	if has_node("TextureProgressBar"):
		health_bar.visible = able_to_be_seen
	if has_node("DropShadow"):
		$DropShadow.visible = able_to_be_seen

	targetable = able_to_be_seen

func get_current_velocity() -> Vector2:
    # Get the direction the sprite is facing (assuming it faces forward on the path)
	var direction_vector = Vector2.RIGHT.rotated(rotation)
	return direction_vector * move_speed * speed_mult

func push_backwards(delta: float):
	# Apply a force in the opposite direction
	progress -= 100 * delta
	if progress < 0:
		progress = 0