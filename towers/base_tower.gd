extends Node2D
class_name Tower

# --- Stats we want to modify in the Inspector ---
@export_category("Tower Stats")
@export var damage: int = 1
@export var attack_range: float = 250.0
@export var fire_rate: float = 1.0 # Seconds between shots
@export var build_cost: int = 100
@export var show_range_setup: bool = false # Debug toggle

# --- State Variables ---
var current_target: Enemy = null
var potential_targets: Array[Enemy] = []
var is_ready_to_fire: bool = true
var path_1_tier: int = 0
var path_2_tier: int = 0
var path_1_upgrades: Dictionary = {}
var path_2_upgrades: Dictionary = {}
var is_selected: bool = false
var sell_value: int = 0

# --- Nodes ---
@onready var detection_shape = $DetectionRange/CollisionShape2D
@onready var reload_timer = $ReloadTimer

func _ready():
	# 1. Apply range to the collision shape physically
	var circle = CircleShape2D.new()
	circle.radius = attack_range
	detection_shape.shape = circle
	
	# 2. Setup Timer
	reload_timer.wait_time = fire_rate
	reload_timer.one_shot = true # We will restart it manually after firing
	
	# 3. Connect Signals
	# Note: We connect these to the PARENT script functions defined below

func _physics_process(_delta):
	update_target()
	
	
	# If we have a target and the gun is loaded... FIRE!
	if current_target != null and is_ready_to_fire and is_turret_aimed():
		fire()
		start_reload()

# --- Logic ---
func update_target():
	# If our current target died or escaped, forget them
	if is_instance_valid(current_target):
		if not current_target.targetable:
			current_target = null
	else:
		current_target = null

	if current_target:
		if not check_line_of_sight(current_target):
			current_target = null

	# If we have no target, try to find one from potential targets
	#if current_target == null and potential_targets.size() > 0:

	var furthest_enemy: Enemy = null
	if potential_targets.size() > 0:
		for enemy in potential_targets:
			if enemy.targetable and check_line_of_sight(enemy):
				if furthest_enemy == null or enemy.progress > furthest_enemy.progress:
					furthest_enemy = enemy
				#current_target = enemy
				#break
		current_target = furthest_enemy

func check_line_of_sight(target_enemy) -> bool:
	# 1. Get the physics state of the world
	var space_state = get_world_2d().direct_space_state
	
	# 2. Create the Ray parameters
	# From: Tower Center
	# To: Enemy Center
	var query = PhysicsRayQueryParameters2D.create(global_position, target_enemy.global_position)
	
	# 3. IMPORTANT: Configure the Ray
	# We only want the Ray to hit WALLS (Layer 1). 
	# If we hit an enemy, that's fine, but walls are the blocker.
	query.collision_mask = 1 # Only scan for World/Walls
	
	# 4. Fire the Ray!
	var result = space_state.intersect_ray(query)
	
	# 5. Interpret Result
	if result:
		# If 'result' is not empty, the ray hit a Wall before reaching the destination
		return false # Vision Blocked!
	else:
		# The ray reached the destination without hitting Layer 1
		return true # Line of Sight Clear!

func start_reload():
	is_ready_to_fire = false
	reload_timer.start()
	await reload_timer.timeout # Wait for the timer to finish
	is_ready_to_fire = true

# --- VIRTUAL FUNCTION (To be overridden) ---
# This function does nothing here. The Washing Machine will "overwrite" this.
func fire():
	pass

# --- Signal Handling ---
func _on_detection_range_area_entered(area):
	# The 'area' is the Hitbox. The Enemy script is on the Hitbox's parent.
	var enemy = area.get_parent()
	
	# Check if the parent is actually an Enemy (using the class_name we set up)
	if enemy is Enemy:
		potential_targets.append(enemy)
		print("Target Acquired: ", enemy.name)

func _on_detection_range_area_exited(area):
	var enemy = area.get_parent()
	
	if enemy in potential_targets:
		potential_targets.erase(enemy)
		if enemy == current_target:
			current_target = null

# VIRTUAL FUNCTION: Child classes can override this to require aiming
func is_turret_aimed():
	return true

func _draw():
	pass

# Function to toggle this on/off from other scripts
func set_range_visible(visibility: bool):
	$RangeIndicator.update_range_visuals(attack_range, visibility)
	queue_redraw() # Tells Godot "The visuals changed, run _draw() again!"

func _on_click_area_mouse_entered():
	# Show range when mouse is over the tower
	if not is_selected:
		set_range_visible(true)

func _on_click_area_mouse_exited():
	# Hide range when mouse leaves
	if not is_selected:
		set_range_visible(false)

func apply_upgrade(path_id: int):
	# Determine which path we are upgrading
	var current_tier = path_1_tier if path_id == 1 else path_2_tier
	var upgrade_list = path_1_upgrades if path_id == 1 else path_2_upgrades
	
	var next_tier = current_tier + 1
	
	# 1. Validation Checks
	if not upgrade_list.has(next_tier):
		print("Path " + str(path_id) + " is maxed out!")
		return

	# Optional: Add BTD Logic (e.g., You can't have Tier 3 in both paths)
	if path_id == 1 and next_tier > 2 and path_2_tier > 2:
		print("Locked! One path is already Tier 3.")
		return
	if path_id == 2 and next_tier > 2 and path_1_tier > 2:
		print("Locked! One path is already Tier 3.")
		return

	var data = upgrade_list[next_tier]

	# 2. Check Money
	if GameData.money >= data["cost"]:
		GameData.remove_money(data["cost"])

		# Add sell value (50% of cost)
		sell_value += int(data["cost"] * 0.5)
		
		# 3. Update the Tier Counter
		if path_id == 1:
			path_1_tier = next_tier
		else:
			path_2_tier = next_tier
			
		# 4. CALL THE SPECIFIC TOWER LOGIC
		# This function will live in "Dryer.gd" or "Washer.gd" to apply the specific stats
		_update_stats(path_id, next_tier)
		
		print("Upgraded Path " + str(path_id) + " to Tier " + str(next_tier))
		
	else:
		print("Not enough cash!")

# Placeholder function that children scripts (Dryer/Washer) will overwrite
func _update_stats(_path_id, _tier):
	pass


# func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
# 	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
# 		select_tower()
# 	elif event is InputEventMouseButton:
# 		print(str(event.pressed) + " " + str(event.button_index))

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# We must check 'event.pressed' to ensure we only fire on the CLICK, not the release.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_tower()
        
        # Optional: Mark the input as handled so it doesn't click through to the floor
		get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton and event.pressed:
		# Debugging other clicks (Right click, etc)
		print("Button: " + str(event.button_index) + " Pressed: " + str(event.pressed))

func select_tower():
	is_selected = true
	# Show the Range
	set_range_visible(true)
	
	# Open the Upgrade Menu
	var upgrade_menu = get_tree().root.get_node("Main/UI/UpgradeMenu")
	if upgrade_menu:
		upgrade_menu.open_menu(self )

# Create a function to "Deselect" (Called later by the UI)
func deselect_tower():
	is_selected = false
	set_range_visible(false)

func add_attack_range(amount: float):
	set_attack_range(attack_range + amount)

func set_attack_range(new_range: float):
	attack_range = new_range
	# Update the collision shape
	$DetectionRange/CollisionShape2D.shape.radius = attack_range
	set_range_visible(true)
