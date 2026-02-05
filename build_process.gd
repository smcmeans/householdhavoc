extends Node2D

# TODO Add a way to remove towers from occupied_tiles when sold

var current_ghost_tower: Node2D = null
var current_tower_cost: int = 0

var occupied_tiles = {}
# [0, 0] is top left
var tower_footprint = [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1, 1)]

@export var FloorLayer: TileMapLayer

var BuildMenu: CanvasLayer

@export var WaveManager: Node

@export var BedroomPortal: Sprite2D
@export var KitchenPortal: Sprite2D

func _ready():

	var build_menu = get_tree().get_first_node_in_group("build_menu")

	build_menu.request_tower_placement.connect(_on_build_requested)

	WaveManager.bedroom_portal_opened.connect(_on_bedroom_portal_opened)
	WaveManager.bedroom_portal_closed.connect(_on_bedroom_portal_closed)
	WaveManager.kitchen_portal_opened.connect(_on_kitchen_portal_opened)
	WaveManager.kitchen_portal_closed.connect(_on_kitchen_portal_closed)

	BedroomPortal.visible = false
	KitchenPortal.visible = false

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
		#print("Mouse Pos: ", mouse_pos)
		
		# Get the Anchor Grid Coordinate
		var tile_pos = FloorLayer.local_to_map(mouse_pos)
		
		# Check Validity
		var is_valid = can_place_tower_at(tile_pos)
		
		# Visual Snap
		# We calculate pixel pos from the GRID, not the mouse, for stability.
		var snap_position = FloorLayer.map_to_local(tile_pos)
		#print("Snap Pos: ", snap_position)


		# VISUAL OFFSET ADJUSTMENT
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

func can_place_tower_at(anchor_grid_pos: Vector2i) -> bool:
	# USE THE SAME FOOTPRINT VARIABLE
	for offset in tower_footprint:
		var check_pos = anchor_grid_pos + offset
			
			# Check A: Terrain
		var data = FloorLayer.get_cell_tile_data(check_pos)
			# Note: Added 'data' check to prevent crash if mouse is outside map
		if not data or not data.get_custom_data("can_build"):
			return false
				
			# Check B: Occupied
		if occupied_tiles.has(check_pos):
			return false
				
	return true

func _on_bedroom_portal_opened():
	BedroomPortal.visible = true
	var anim = BedroomPortal.get_parent().get_node("AnimationPlayer")
	anim.play("portal_swoosh")

func _on_bedroom_portal_closed():
	BedroomPortal.visible = false
	var anim = BedroomPortal.get_parent().get_node("AnimationPlayer")
	anim.play("RESET")

func _on_kitchen_portal_opened():
	KitchenPortal.visible = true
	var anim = KitchenPortal.get_parent().get_node("AnimationPlayer")
	anim.play("portal_swoosh")

func _on_kitchen_portal_closed():
	KitchenPortal.visible = false
	var anim = KitchenPortal.get_parent().get_node("AnimationPlayer")
	anim.play("RESET")
