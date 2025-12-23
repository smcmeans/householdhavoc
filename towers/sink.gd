extends ProjectileTower

@export var burst_amount: int = 3
@export var spread_angle_degrees: float = 30.0

var dish_washer_mode: bool = false
var utensils_washed: Array = []
var damp_duration: int = 5
var throw_distance: float = 200.0

func _ready():
	super()
	path_1_upgrades = {
		1: { "name": "Hot water", "cost": 200, "icon": null, "description": "Increases water damage." },
		2: { "name": "More spray",    "cost": 400, "icon": null, "description": "Increases water sprayed and range." },
		3: { "name": "Spray Nozell",  "cost": 1200,"icon": null, "description": "Sprays all around the sink." }
	}

	path_2_upgrades = {
		1: { "name": "Hard water",   "cost": 100, "icon": null, "description": "Water pierces more enemies" },
		2: { "name": "Better piping",  "cost": 300, "icon": null, "description": "Increases range of sink" },
		3: { "name": "Dish washer", "cost": 1600,"icon": null, "description": "Sink can wash utensils" }
	}

func _physics_process(delta):
	super(delta)
	if dish_washer_mode:
		suck_utensils()
		wash_utensils(delta)

func fire():
	# 1. Convert spread to radians for math
	var total_spread = deg_to_rad(spread_angle_degrees)
	
	# 2. Calculate where the "Fan" starts (Left side of the aim)
	var start_angle = -total_spread / 2.0
	
	# 3. Calculate the step between each bullet
	# Avoid division by zero if burst_amount is 1
	var angle_step = 0
	if burst_amount > 1:
		angle_step = total_spread / (burst_amount - 1)

	# 4. Loop through each bullet
	for i in range(burst_amount):
		var water = create_projectile() 
	
		# Calculate the specific offset for this bullet index 'i'
		var current_offset = start_angle + (i * angle_step)
		
		# Add that offset to the Pivot's current rotation
		var final_angle = pivot.rotation + current_offset
		
		# Apply direction
		water.direction = Vector2.RIGHT.rotated(final_angle)
		water.rotation = final_angle # Rotate sprite too
		
		# Add to scene
		get_tree().root.add_child(water)

func _update_stats(path_id, tier):
	if path_id == 1:
		if tier == 1:
			damage += 2
		elif tier == 2:
			spread_angle_degrees += 20.0
			burst_amount += 2
		elif tier == 3:
			spread_angle_degrees = 360.0
			burst_amount = 36
	elif path_id == 2:
		if tier == 1:
			projectile_piercing += 2
		elif tier == 2:
			add_attack_range(50)
		elif tier == 3:
			dish_washer_mode = true

func suck_utensils():

	# Use the area from BaseTower
	var targets_in_range = $DetectionRange.get_overlapping_areas()
	
	for area in targets_in_range:

		if not is_instance_valid(area):
			continue

		var enemy = area.get_parent()
		
		if enemy is Enemy and enemy.category == "utensil" and not enemy.is_trapped and not enemy.has_status("clean"):
			enemy.is_trapped = true

			var track_position = enemy.global_position

			utensils_washed.append({
				"enemy": enemy,
				"timer": -0.5,
				"original_pos": track_position
			})
			
			var tween = get_tree().create_tween()
			tween.tween_property(enemy, "global_position", global_position, 0.5)
			await tween.finished

			if not is_instance_valid(enemy):
				continue

			enemy.set_trapped(true)
			

func wash_utensils(delta):
	# Loop backwards to safely remove items
	for i in range(utensils_washed.size() - 1, -1, -1):
		var utensil = utensils_washed[i]
		var enemy = utensil["enemy"]
		
		if not is_instance_valid(enemy):
			utensils_washed.remove_at(i)
			continue
			
		utensil["timer"] += delta
		
		# USE PARENT VARIABLE: attack_speed determines how long they stay inside
		if utensil["timer"] >= fire_rate:
			eject_utensils(utensil)
			utensils_washed.remove_at(i)

func eject_utensils(enemy_data):

	var enemy = enemy_data["enemy"]
	# Apply burning status
	enemy.apply_status("clean", damp_duration)
	
	# Make them visible again immediately
	if enemy.has_node("Sprite2D"):
		var sprite = enemy.get_node("Sprite2D")
		enemy.visibility(true)

		var start_pos = global_position
		enemy.progress += throw_distance
		sprite.global_position = start_pos
	
		# Create the Tween 
		var tween = get_tree().create_tween()
	
		tween.tween_property(sprite, "position", Vector2.ZERO, 0.5)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	
		# Wait for the tween to finish
		await tween.finished

	if is_instance_valid(enemy):
		enemy.set_trapped(false)
		enemy.take_damage(damage)
	