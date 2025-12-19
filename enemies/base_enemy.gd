extends PathFollow2D
class_name Enemy

@export var move_speed: float = 150.0
@export var max_health: int = 5
@export var money_reward: int = 5

@onready var health_bar = $ProgressBar

@onready var sprite = $Sprite2D
var default_color = Color(1, 1, 1, 1)
var is_trapped: bool = false
var targetable: bool = true
 
var current_health: int
var active_statuses: Dictionary = {}

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

func _physics_process(delta):
	# Do not move if trapped
	if (is_trapped):
		return

	progress += move_speed * delta * status_speed_effect()
	take_damage(status_damage_over_time(delta))
	if progress_ratio >= 1.0:
		escape_house()
	handle_statuses(delta)

func status_speed_effect():
	var speed_mult = 1
	if has_status("damp"):
		speed_mult *= 0.8
	if has_status("frozen"):
		speed_mult = 0
	if has_status("burning"):
		speed_mult *= 1.2
	return speed_mult

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
		if has_status("burning"):
			remove_status("burning")
			apply_status_helper("dry", 5.0)
			# TODO: Add steam blast
			return
		if has_status("dry"):
			return
	
	apply_status_helper(effect_name, duration)

func apply_status_helper(effect_name: String, duration: float):
	# Add or refresh the status
	active_statuses[effect_name] = duration
	
	# Update visuals immediately
	update_status_visuals()
	print(name + " applied status: " + effect_name)

func remove_status(effect_name: String):
	if has_status(effect_name):
		active_statuses.erase(effect_name)
		update_status_visuals()
		print(name + " removed status: " + effect_name)

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
	if has_node("ProgressBar"):
		health_bar.visible = able_to_be_seen

	targetable = able_to_be_seen
