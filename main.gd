extends Node2D

var current_ghost_tower: Node2D = null
var current_tower_cost: int = 0

# Link the signal from the menu
func _ready():
	$BuildMenu.request_tower_placement.connect(_on_build_requested)

func _on_build_requested(tower_scene, cost):
	current_tower_cost = cost
	
	current_ghost_tower = tower_scene.instantiate()
	add_child(current_ghost_tower)
	
	# Make it transparent
	current_ghost_tower.modulate = Color(1, 1, 1, 0.5)
	
	# Disable logic
	current_ghost_tower.process_mode = Node.PROCESS_MODE_DISABLED
	
	# FORCE THE RANGE TO BE VISIBLE
	current_ghost_tower.set_range_visible(true)

func _process(delta):
	# If we are holding a ghost, make it follow the mouse
	if current_ghost_tower != null:
		# Snap to mouse position
		current_ghost_tower.global_position = get_global_mouse_position()
		
		# Checking for "Left Click" to place it
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			place_tower()

func place_tower():
	# 1. (Optional) Check if we have enough money here
	
	# 2. Make the ghost "Real"
	current_ghost_tower.modulate = Color(1, 1, 1, 1) # Fully visible
	current_ghost_tower.process_mode = Node.PROCESS_MODE_INHERIT # Turn brain back on
	
	# 3. Forget the ghost (so we stop moving it)
	current_ghost_tower = null
	print("Tower placed!")

	# 4. Deduct money
	GameData.remove_money(current_tower_cost)
