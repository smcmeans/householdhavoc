extends Node2D

var current_ghost_tower: Node2D = null
var current_tower_cost: int = 0

var occupied_tiles = {}
# [0, 0] is top left
var tower_footprint = [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1, 1)]

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
	if current_ghost_tower != null:
		var mouse_pos = get_global_mouse_position()
        
        # 1. Get the Anchor Grid Coordinate
		var tile_pos = $FloorLayer.local_to_map(mouse_pos)
        
        # 2. Check Validity
		var is_valid = can_place_tower_at(tile_pos)
        
        # 3. Visual Snap
        # We calculate pixel pos from the GRID, not the mouse, for stability.
		var snap_position = $FloorLayer.map_to_local(tile_pos)
        
        # VISUAL OFFSET ADJUSTMENT
		snap_position.x += 8 
		snap_position.y += 24 
        
		current_ghost_tower.global_position = snap_position

        # 4. Color Logic
		if not is_valid:
			current_ghost_tower.modulate = Color(1, 0, 0, 0.5)
		else:
			current_ghost_tower.modulate = Color(1, 1, 1, 0.5)
            
        # 5. Placement
		if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and is_valid:
            # PASS THE GRID COORD, NOT PIXEL POS
			place_tower(tile_pos, snap_position)

func place_tower(grid_pos: Vector2i, pixel_pos: Vector2):
    
	current_ghost_tower.modulate = Color(1, 1, 1, 1)
	current_ghost_tower.process_mode = Node.PROCESS_MODE_INHERIT
	current_ghost_tower.global_position = pixel_pos # Ensure it stays exactly where the ghost was
    
	current_ghost_tower = null
	print("Tower placed at ", grid_pos)

    # USE THE SAME FOOTPRINT VARIABLE
	for offset in tower_footprint:
		var mark_pos = grid_pos + offset
		occupied_tiles[mark_pos] = true
        
	GameData.remove_money(current_tower_cost)
    # print(str(occupied_tiles))

func can_place_tower_at(anchor_grid_pos: Vector2i) -> bool:
    # USE THE SAME FOOTPRINT VARIABLE
	for offset in tower_footprint:
		var check_pos = anchor_grid_pos + offset
			
			# Check A: Terrain
		var data = $FloorLayer.get_cell_tile_data(check_pos)
			# Note: Added 'data' check to prevent crash if mouse is outside map
		if not data or not data.get_custom_data("can_build"):
			return false
				
			# Check B: Occupied
		if occupied_tiles.has(check_pos):
			return false
				
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
