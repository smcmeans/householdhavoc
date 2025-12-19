extends Node2D

var current_ghost_tower: Node2D = null
var current_tower_cost: int = 0

var occupied_tiles = {}
var tower_footprint = [Vector2i(1,0), Vector2i(2,0), Vector2i(1,1), Vector2i(2,1)]

# Link the signal from the menu
func _ready():
	$BuildMenu.request_tower_placement.connect(_on_build_requested)
	$WaveManager.bedroom_portal_opened.connect(_on_bedroom_portal_opened)
	$WaveManager.bedroom_portal_closed.connect(_on_bedroom_portal_closed)
	$WaveManager.kitchen_portal_opened.connect(_on_kitchen_portal_opened)
	$WaveManager.kitchen_portal_closed.connect(_on_kitchen_portal_closed)

	$LevelMap/BedroomPath/Portal.visible = false
	$LevelMap/KitchenPath/Portal.visible = false


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

		var mouse_pos = get_global_mouse_position()
		mouse_pos.y += 13 # Adjust for tile offset
		mouse_pos.x += 3  # Adjust for tile offset

		# Snap to mouse position
		var tile_pos = $FloorLayer.local_to_map(mouse_pos)
		
		# Get the pixel center of that tile (e.g., Vector2(176, 112))
		var snap_position = $FloorLayer.map_to_local(tile_pos)

		current_ghost_tower.global_position = snap_position

		if not can_place_tower_at(tile_pos):
			current_ghost_tower.modulate = Color(1, 0, 0, 0.5) # Red tint
		else:
			current_ghost_tower.modulate = Color(1, 1, 1, 1) # Normal
			
		# Checking for "Left Click" to place it
		if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and can_place_tower_at(tile_pos):
			place_tower(snap_position)

func place_tower(location):
	
	# 2. Make the ghost "Real"
	current_ghost_tower.modulate = Color(1, 1, 1, 1) # Fully visible
	current_ghost_tower.process_mode = Node.PROCESS_MODE_INHERIT # Turn brain back on
	
	# 3. Forget the ghost (so we stop moving it)
	current_ghost_tower = null
	print("Tower placed!")

	var grid_pos = $FloorLayer.local_to_map(location)
	for offset in tower_footprint:
		var mark_pos = grid_pos + offset
		occupied_tiles[mark_pos] = true
	# 4. Deduct money
	GameData.remove_money(current_tower_cost)
	print(str(occupied_tiles))

func can_place_tower_at(anchor_grid_pos: Vector2i) -> bool:
	# 1. Get the "Anchor" grid position from the mouse
	
	# 2. Check EVERY tile in the footprint
	for offset in tower_footprint:
		var check_pos = anchor_grid_pos + offset
		
		# Check A: Is this specific tile buildable terrain?
		var data = $FloorLayer.get_cell_tile_data(check_pos)
		if not data or not data.get_custom_data("can_build"):
			return false
			
		# Check B: Is this specific tile already occupied?
		if occupied_tiles.has(check_pos):
			return false
			
	# 3. If we survived the loop, ALL tiles are clear!
	return true

func _on_bedroom_portal_opened():
	$LevelMap/BedroomPath/Portal.visible = true
	$LevelMap/BedroomPath/AnimationPlayer.play("portal_swoosh")

func _on_bedroom_portal_closed():
	$LevelMap/BedroomPath/Portal.visible = false
	$LevelMap/BedroomPath/AnimationPlayer.play("RESET")

func _on_kitchen_portal_opened():
	$LevelMap/KitchenPath/Portal.visible = true
	$LevelMap/KitchenPath/AnimationPlayer.play("portal_swoosh")

func _on_kitchen_portal_closed():
	$LevelMap/KitchenPath/Portal.visible = false
	$LevelMap/KitchenPath/AnimationPlayer.play("RESET")
