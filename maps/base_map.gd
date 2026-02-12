extends Node2D
class_name BaseMap

var current_ghost_tower: Node2D = null
var current_tower_cost: int = 0

var occupied_tiles = {}
# [0, 0] is top left
# var tower_footprint = [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1, 1)]

@export var floor_layer: TileMapLayer

var build_menu: CanvasLayer

@export var map_wave_manager: Node

#@export var upgrade_menu: Control

func check_for_undefined() -> bool:
	var returned_value = true
	print("Checking for undefined variables in map")
	if floor_layer == null:
		print("Warning: floor_layer is not found!")
		returned_value = false
	if map_wave_manager == null:
		print("Warning: map_wave_manager is not assigned!")
		returned_value = false
	if build_menu == null:
		print("Warning: build_menu node not found in group 'build_menu'!")
		returned_value = false
	return returned_value

func _ready():

	build_menu = get_tree().get_first_node_in_group("build_menu")

	if check_for_undefined() == false:
		print("Error: Undefined variables found!")
		return
	else:
		print("All variables defined. Map ready.")

	build_menu.request_tower_placement.connect(_on_build_requested)
	#upgrade_menu.request_tower_removal.connect(_on_tower_removal_requested)

func _on_build_requested(tower_scene, cost):
	
	print("Build requested for tower with cost: ", cost)

	current_tower_cost = cost
	
	current_ghost_tower = tower_scene.instantiate()
	add_child(current_ghost_tower)
	
	# Make it transparent
	current_ghost_tower.modulate = Color(1, 1, 1, 0.5)
	
	# Disable logic
	current_ghost_tower.process_mode = Node.PROCESS_MODE_DISABLED
	
	# FORCE THE RANGE TO BE VISIBLE
	current_ghost_tower.set_range_visible(true)

func _process(_delta):
	if current_ghost_tower != null:
		if Input.is_action_just_pressed("ui_cancel"):
			# Cancel placement
			current_ghost_tower.queue_free()
			current_ghost_tower = null
			return


		var mouse_pos = get_global_mouse_position()
		mouse_pos.x -= 8  # Adjust for cursor hotspot
		mouse_pos.y -= 8  # Adjust for cursor hotspot
		#print("Mouse Pos: ", mouse_pos)
		
		# Get the Anchor Grid Coordinate
		var tile_pos = floor_layer.local_to_map(mouse_pos)
		#print("Tile Pos: ", tile_pos)
		
		# Check Validity
		var tower_footprint = current_ghost_tower.tile_size
		var is_valid = can_place_tower_at(tile_pos, tower_footprint)
		
		# Visual Snap
		# This calculated the center of the tile, we want top-left
		var snap_position = floor_layer.map_to_local(tile_pos)
		#print("Snap Pos: ", snap_position)

		snap_position.x += 8 
		snap_position.y += 24 
		
		current_ghost_tower.global_position = snap_position

		# Color Logic
		if not is_valid:
			current_ghost_tower.modulate = Color(1, 0, 0, 0.5)
		else:
			current_ghost_tower.modulate = Color(1, 1, 1, 0.5)
			
		# Placement
		if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and is_valid:
			# PASS THE GRID COORD, NOT PIXEL POS
			place_tower(tile_pos, snap_position)

func place_tower(grid_pos: Vector2i, pixel_pos: Vector2):
	
	current_ghost_tower.modulate = Color(1, 1, 1, 1)
	current_ghost_tower.process_mode = Node.PROCESS_MODE_INHERIT
	current_ghost_tower.global_position = pixel_pos # Ensure it stays exactly where the ghost was
	current_ghost_tower.tile_position = grid_pos # Set the position for future reference
	var tower_footprint = current_ghost_tower.tile_size
	# Select the tower
	current_ghost_tower.select_tower()

	current_ghost_tower = null
	print("Tower placed at ", grid_pos)

	# USE THE SAME FOOTPRINT VARIABLE
	for offset in tower_footprint:
		var mark_pos = grid_pos + offset
		occupied_tiles[mark_pos] = true
		
	GameData.remove_money(current_tower_cost)
	# print(str(occupied_tiles))

func can_place_tower_at(anchor_grid_pos: Vector2i, tower_footprint: Array) -> bool:
	# USE THE SAME FOOTPRINT VARIABLE
	for offset in tower_footprint:
		var check_pos = anchor_grid_pos + offset
			
			# Check A: Terrain
		var data = floor_layer.get_cell_tile_data(check_pos)
			# Note: Added 'data' check to prevent crash if mouse is outside map
		if not data or not data.get_custom_data("can_build"):
			return false
				
			# Check B: Occupied
		if occupied_tiles.has(check_pos):
			return false
				
	return true

func remove_tower_at(anchor_grid_pos: Vector2i, tower_footprint: Array):
	for offset in tower_footprint:
		var mark_pos = anchor_grid_pos + offset
		occupied_tiles.erase(mark_pos)
