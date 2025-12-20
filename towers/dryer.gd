extends Tower 

# Settings
@export var capacity: int = 3
@export var suck_speed: float = 0.5
@export var throw_distance: float = 150.0
@export var burn_duration: float = 5.0

# Storage for enemies currently inside: [{ "enemy": Node, "timer": Float }]
var laundry_load: Array = []

#@onready var anim_player = $AnimationPlayer 

func _ready():
	super()
	# Path 1: Usually Utility (Speed, Range, Capacity)
	path_1_upgrades = {
		1: { "name": "Lint Roller", "cost": 150, "icon": null, "description": "Increases range by 50." },
		2: { "name": "High RPM",    "cost": 400, "icon": null, "description": "Attacks 20% faster." },
		3: { "name": "Industrial",  "cost": 1200,"icon": null, "description": "Huge range and speed boost." }
	}

	# Path 2: Usually Damage (Power, Status Effects)
	path_2_upgrades = {
		1: { "name": "Hot Coils",   "cost": 200, "icon": null, "description": "+1 Damage." },
		2: { "name": "Steam Vent",  "cost": 550, "icon": null, "description": "Applies burning for longer." },
		3: { "name": "Plasma Heat", "cost": 1500,"icon": null, "description": "damages all trapped enemies." }
	}

func _physics_process(delta):
	# We override the default tower behavior because we don't shoot bullets
	# 1. SUCK NEW ENEMIES IN
	suck_enemies()
	
	# 2. PROCESS EXISTING LAUNDRY
	process_laundry(delta)

func suck_enemies():
	if laundry_load.size() >= capacity:
		return

	# Use the area from BaseTower
	var targets_in_range = $DetectionRange.get_overlapping_areas()
	
	for area in targets_in_range:

		if not is_instance_valid(area):
			continue

		var enemy = area.get_parent()
		
		# LOGIC: Enemy + DAMP + Not already trapped
		if enemy is Enemy and enemy.has_status("damp") and not enemy.is_trapped:
			print(str(laundry_load.size()) + " / " + str(capacity) + " laundry slots used.")
			enemy.is_trapped = true

			var track_position = enemy.global_position

			laundry_load.append({
				"enemy": enemy,
				"timer": -suck_speed,
				"original_pos": track_position
			})
			
			var tween = get_tree().create_tween()
			tween.tween_property(enemy, "global_position", global_position, suck_speed)
			await tween.finished

			if not is_instance_valid(enemy):
				continue

			enemy.set_trapped(true)
			
			

			if laundry_load.size() >= capacity:
				break

func process_laundry(delta):
	if laundry_load.size() == 0:
		# if anim_player and anim_player.current_animation == "Rumble":
		#     anim_player.play("Idle")
		return

	# if anim_player and anim_player.current_animation != "Rumble":
	#     anim_player.play("Rumble")

	# Loop backwards to safely remove items
	for i in range(laundry_load.size() - 1, -1, -1):
		var load_item = laundry_load[i]
		var enemy = load_item["enemy"]
		
		if not is_instance_valid(enemy):
			laundry_load.remove_at(i)
			continue
			
		load_item["timer"] += delta
		
		# USE PARENT VARIABLE: attack_speed determines how long they stay inside
		if load_item["timer"] >= fire_rate:
			eject_enemy(load_item)
			laundry_load.remove_at(i)

func eject_enemy(enemy_data):

	var enemy = enemy_data["enemy"]
	# Apply burning status
	enemy.apply_status("burning", burn_duration)
	
	# Make them visible again immediately
	if enemy.has_node("Sprite2D"):
		var sprite = enemy.get_node("Sprite2D")
		enemy.visibility(true)

		var start_pos = global_position
		enemy.progress += throw_distance
		sprite.global_position = start_pos
	
		# Create the Tween (Fly back to track)
		var tween = get_tree().create_tween()
	
		# Tween from CURRENT position (Dryer) -> TARGET position (Track)
		# Duration: 0.3 seconds
		tween.tween_property(sprite, "position", Vector2.ZERO, suck_speed)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	
		# Wait for the tween to finish
		await tween.finished

	if is_instance_valid(enemy):
		enemy.set_trapped(false)
		enemy.take_damage(damage)

func _update_stats(path_id, tier):
	# PATH 1: SPEED & UTILITY
	if path_id == 1:
		if tier == 1:
			attack_range += 50
			# Update the collision shape
			$DetectionRange/CollisionShape2D.shape.radius = attack_range
			set_range_visible(true)
		elif tier == 2:
			fire_rate *= 0.8 # Lower is faster (20% reduction)
		elif tier == 3:
			capacity += 2 # Can hold more laundry!

	# PATH 2: DAMAGE & FIRE
	elif path_id == 2:
		if tier == 1:
			damage += 1
		elif tier == 2:
			burn_duration += 3.0 # Longer burn time
		elif tier == 3:
			throw_distance += 100 # Launch them further!
