extends Node

@export var path_bedroom: Path2D
@export var path_kitchen: Path2D

var bedroom_enemies: Array
var kitchen_enemies: Array

var rooms_finished = {
	"bedroom": true,
	"kitchen": true
}

signal enable_wave_button
signal bedroom_portal_opened
signal kitchen_portal_opened
signal bedroom_portal_closed
signal kitchen_portal_closed

# Configure your catalog here
# Format: "Name": { "scene": PreloadedScene, "cost": PointValue }
var bedroom_enemy_catalog = {
	"Sock": {
		"scene": preload("res://enemies/Sock.tscn"),
		"cost": 1,
		"wave": 1
	},
	"Pants": {
		"scene": preload("res://enemies/Pants.tscn"),
		"cost": 5,
		"wave": 2
	},
	"Shirt": {
		"scene": preload("res://enemies/Shirt.tscn"),
		"cost": 8,
		"wave": 5
	},
	"Shoes": {
		"scene": preload("res://enemies/Shoes.tscn"),
		"cost": 12,
		"wave": 10
	},
	"Glasses": {
		"scene": preload("res://enemies/Glasses.tscn"),
		"cost": 5,
		"wave": 13

	},
	"Hat": {
		"scene": preload("res://enemies/Hat.tscn"),
		"cost": 25,
		"wave": 15
	},
}

var bedroom_boss_catalog = {
	"Outfit": {
		"scene": preload("res://enemies/Outfit.tscn"),
		"cost": 1,
		"wave": 10
	},
	"BedMonster": {
		"scene": preload("res://enemies/BedMonster.tscn"),
		"cost": 2,
		"wave": 20
	},
}

var kitchen_enemy_catalog = {
	"Spoon": {
		"scene": preload("res://enemies/Spoon.tscn"),
		"cost": 10,
		"wave": 20
	},
	"Fork": {
		"scene": preload("res://enemies/Fork.tscn"),
		"cost": 10,
		"wave": 15
	},
	"Apple": {
		"scene": preload("res://enemies/Apple.tscn"),
		"cost": 5,
		"wave": 10
	},
	"Banana": {
		"scene": preload("res://enemies/Banana.tscn"),
		"cost": 5,
		"wave": 15
	},
}

var kitchen_boss_catalog = {
	"Spork": {
		"scene": preload("res://enemies/Spork.tscn"),
		"cost": 1,
		"wave": 0
	},
	"Sandwich": {
		"scene": preload("res://enemies/Sandwich.tscn"),
		"cost": 2,
		"wave": 20
	},
}

@onready var bedroom_timer = $BedroomTimer
@onready var kitchen_timer = $KitchenTimer

func start_next_wave():
	print("--- Starting Wave ", GameData.current_round, " ---")

	# Calculate Budget (Formula: Wave 1 = 10, Wave 2 = 15, etc.)
	var budget = GameData.current_round * 5
	print("Wave Budget: ", budget)
	
	# Bedroom
	rooms_finished["bedroom"] = false
	if is_boss_round():
		bedroom_enemies = create_boss_wave(GameData.current_round, bedroom_boss_catalog)
	else:
		bedroom_enemies = generate_wave_queue(budget, bedroom_enemy_catalog)
	emit_signal("bedroom_portal_opened")
	bedroom_timer.start(0.5)
	
	# Kitchen
	if GameData.current_round > 10:
		rooms_finished["kitchen"] = false
		emit_signal("kitchen_portal_opened")
		if is_boss_round():
			kitchen_enemies = create_boss_wave(GameData.current_round, kitchen_boss_catalog)
		else:
			kitchen_enemies = generate_wave_queue(budget, kitchen_enemy_catalog)
		kitchen_timer.start(0.5)
	
	

func generate_wave_queue(budget: int, catalog: Dictionary) -> Array:
	var enemies_to_spawn = []
	
	# Safety loop to prevent infinite freezing if math goes wrong
	var sanity_check = 1000
	
	while budget > 0 and sanity_check > 0:
		sanity_check -= 1
		
		# 1. Filter: Find affordable enemies
		var affordable_options = []
		for key in catalog:
			if catalog[key]["cost"] <= budget and catalog[key]["wave"] <= GameData.current_round:
				affordable_options.append(key)
		
		if affordable_options.size() == 0:
			break # We are broke! Stop shopping.

		# 2. Pick an Enemy Type
		var pick_name = affordable_options.pick_random()
		var entry = catalog[pick_name]
		var unit_cost = entry["cost"]
		
		# 3. DYNAMIC RUSH CHANCE
		# If we have lots of money, high chance to rush.
		# If budget is 50, chance is 100% (1.0). If budget is 5, chance is 10% (0.1).
		# We clamp it between 20% and 90% so it's never impossible/guaranteed.
		var rush_chance = clamp(budget / 40.0, 0.2, 0.9)
		
		# Check if we can afford at least 3 of them to make a "Rush"
		var can_afford_rush = (budget >= unit_cost * 3)
		var is_rush = (randf() < rush_chance) and can_afford_rush
		
		if is_rush:
			# --- RUSH LOGIC ---
			# Determine max size based on budget, but cap it (e.g., max 8 at a time)
			var max_possible = floor(budget / unit_cost)
			var rush_size = randi_range(3, min(max_possible, 8))
			
			# Decide: Do we "Stack" this rush into the next one?
			# 50% chance the LAST enemy has a short delay (fast transition)
			# 50% chance the LAST enemy has a long delay (pause after rush)
			var stack_next = (randf() < 0.5)
			
			for i in range(rush_size):
				var is_last_in_batch = (i == rush_size - 1)
				var current_delay = 0.1 # Default rush speed
				
				# If this is the last one, decide the delay for the NEXT group
				if is_last_in_batch:
					if stack_next:
						current_delay = 0.2 # Short gap (Stacking!)
					else:
						current_delay = 2.0 # Long gap (Breather)
				
				enemies_to_spawn.append({
					"scene": entry["scene"],
					"delay": current_delay
				})
				budget -= unit_cost
				
			print("Queue: Added Rush of ", rush_size, " ", pick_name, "s (Stacked: ", stack_next, ")")
			
		else:
			# --- SINGLE LOGIC ---
			enemies_to_spawn.append({
				"scene": entry["scene"],
				"delay": randf_range(0.8, 1.5) # Randomize walking pace slightly
			})
			budget -= unit_cost
			print("Queue: Added Single ", pick_name)
			
	return enemies_to_spawn

func _on_bedroom_timer_timeout():
	_spawn_enemy_on_path(bedroom_enemies, path_bedroom, bedroom_timer, "bedroom", "bedroom_portal_closed")

func _on_kitchen_timer_timeout():
	_spawn_enemy_on_path(kitchen_enemies, path_kitchen, kitchen_timer, "kitchen", "kitchen_portal_closed")
	
func _spawn_enemy_on_path(enemies: Array, path: Path2D, timer: Timer, room: String, portal_closed_signal: String):
	var boss_chance = 0.01 * (GameData.current_round / 10)
	if boss_chance > 0.9:
		boss_chance = 0.9

	if enemies.size() == 0:
		timer.stop()
		return
	var enemy_data = enemies.pop_front()
	
	var new_enemy = enemy_data["scene"].instantiate()
	path.add_child(new_enemy)
	if randf() < boss_chance and not new_enemy.is_boss:
		new_enemy.set_boss_enemy()
		print("A Boss Enemy has spawned!")

	if enemies.size() > 0:
		# We still have enemies! Schedule the next one.
		var next_delay = enemies[0]["delay"] # Peek at the next delay
		timer.start(next_delay)
	else:
		# The list is now empty! We just spawned the last one.
		print("Wave Spawning Finished! Last enemy spawned.")
		timer.stop()
		rooms_finished[room] = true
		emit_signal(portal_closed_signal)
		check_all_finished()

func check_all_finished():
	for room in rooms_finished.keys():
		if not rooms_finished[room]:
			return
	emit_signal("enable_wave_button")
	GameData.round_complete()

func is_boss_round() -> bool:
	return GameData.current_round % 10 == 0

func create_boss_wave(round_number: int, room_boss_catalog: Dictionary) -> Array:
	var boss_wave = []
	var budget = round_number / 10
	
	var previous_bosses = []
	for boss_name in room_boss_catalog.keys():
		var boss_info = room_boss_catalog[boss_name]
		if boss_info["wave"] == round_number:
			boss_wave.append({
				"scene": boss_info["scene"],
				"delay": 0.0
			})
			print("Boss Wave: Added Boss ", boss_name)
		else:
			previous_bosses.append(boss_name)

	while budget > 0:
		if previous_bosses.size() == 0:
			break
		var affordable_bosses = []
		for boss_name in previous_bosses:
			var boss_info = room_boss_catalog[boss_name]
			if boss_info["cost"] <= budget:
				affordable_bosses.append(boss_name)
		if affordable_bosses.size() == 0:
			break
		var pick_name = affordable_bosses.pick_random()
		var boss_info = room_boss_catalog[pick_name]
		boss_wave.append({
			"scene": boss_info["scene"],
			"delay": randf_range(0.8, 1.5)
		})
		budget -= boss_info["cost"]
		print("Boss Wave: Added Previous Boss ", pick_name)
		

	return boss_wave
	

		
