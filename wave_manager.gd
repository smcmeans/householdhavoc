extends Node

# Link your Path2D here in the Inspector!
@export var path_to_follow: Path2D

signal enable_wave_button

# Configure your catalog here
# Format: "Name": { "scene": PreloadedScene, "cost": PointValue }
var enemy_catalog = {
	"Sock": {
		"scene": preload("res://enemies/Sock.tscn"),
		"cost": 1
	},
	# If you don't have a Shirt yet, just use Sock but pretend it costs 5
	"Shirt": {
		"scene": preload("res://enemies/Shirt.tscn"), # Change to Shirt.tscn later!
		"cost": 5
	}
}

var current_wave: int = 0
var enemies_to_spawn: Array = [] # A list (queue) of enemies waiting to enter

@onready var spawn_timer = $SpawnTimer

func start_next_wave():
	current_wave += 1
	print("--- Starting Wave ", current_wave, " ---")
	
	# 1. Calculate Budget (Formula: Wave 1 = 10, Wave 2 = 15, etc.)
	var budget = 5 + (current_wave * 5)
	print("Wave Budget: ", budget)
	
	# 2. Go Shopping
	generate_wave_queue(budget)
	
	# 3. Start Spawning
	spawn_timer.start()

func generate_wave_queue(budget):
	enemies_to_spawn.clear()
	
	# Safety loop to prevent infinite freezing if math goes wrong
	var sanity_check = 1000
	
	while budget > 0 and sanity_check > 0:
		sanity_check -= 1
		
		# 1. Filter: Find affordable enemies
		var affordable_options = []
		for key in enemy_catalog:
			if enemy_catalog[key]["cost"] <= budget:
				affordable_options.append(key)
		
		if affordable_options.size() == 0:
			break # We are broke! Stop shopping.

		# 2. Pick an Enemy Type
		var pick_name = affordable_options.pick_random()
		var entry = enemy_catalog[pick_name]
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
			
	# Trigger start
	if enemies_to_spawn.size() > 0:
		spawn_timer.start(1.0)

func _on_spawn_timer_timeout():
	if enemies_to_spawn.size() == 0:
		spawn_timer.stop()
		return

	var enemy_data = enemies_to_spawn.pop_front()
	
	var new_enemy = enemy_data["scene"].instantiate()
	path_to_follow.add_child(new_enemy)
	
	if enemies_to_spawn.size() > 0:
		# We still have enemies! Schedule the next one.
		var next_delay = enemies_to_spawn[0]["delay"] # Peek at the next delay
		spawn_timer.start(next_delay)
	else:
		# The list is now empty! We just spawned the last one.
		print("Wave Spawning Finished! Last enemy spawned.")
		emit_signal("enable_wave_button")
		spawn_timer.stop()
