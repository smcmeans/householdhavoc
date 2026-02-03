extends Tower 

# Settings
@export var capacity: int = 3
@export var throw_distance: float = 150.0

# Storage for enemies currently inside: [{ "enemy": Node, "timer": Float }]
var blend_load: Array = []

#@onready var anim_player = $AnimationPlayer 

func _ready():
	super()
	# path_1_upgrades = {
	# 	1: { "name": "Lint Roller", "cost": 150, "icon": null, "description": "Increases range." },
	# 	2: { "name": "High RPM",    "cost": 200, "icon": null, "description": "Attacks 20% faster." },
	# 	3: { "name": "Spring Loaded",  "cost": 800,"icon": null, "description": "Pushes enemies backwards." }
	# }

	# path_2_upgrades = {
	# 	1: { "name": "Hot Coils",   "cost": 100, "icon": null, "description": "+1 Damage." },
	# 	2: { "name": "Steam Vent",  "cost": 400, "icon": null, "description": "Applies burning for longer." },
	# 	3: { "name": "Industrial", "cost": 900,"icon": null, "description": "Increases capacity greatly." }
	# }

func _physics_process(delta):
	# Override the default tower behavior because it doesn't shoot bullets
	grab_enemies()
	
	blend(delta)

func grab_enemies():
	if blend_load.size() >= capacity:
		return

	var targets_in_range = $DetectionRange.get_overlapping_areas()
	
	for area in targets_in_range:

		if not is_instance_valid(area):
			continue

		var enemy = area.get_parent()
		
		# Enemy + Not already trapped
		if enemy is Enemy and not enemy.is_trapped:
			print(str(blend_load.size()) + " / " + str(capacity) + " laundry slots used.")
			enemy.is_trapped = true

			var track_position = enemy.global_position

			blend_load.append({
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
			
			

			if blend_load.size() >= capacity:
				break

func blend(delta):
	if blend_load.size() == 0:
		# if anim_player and anim_player.current_animation == "Rumble":
		#     anim_player.play("Idle")
		return

	# if anim_player and anim_player.current_animation != "Rumble":
	#     anim_player.play("Rumble")

	# Loop backwards to safely remove items
	for i in range(blend_load.size() - 1, -1, -1):
		var load_item = blend_load[i]
		var enemy = load_item["enemy"]
		
		if not is_instance_valid(enemy):
			blend_load.remove_at(i)
			continue
			
		load_item["timer"] += delta
		
		# fire_rate determines how long they stay inside
		if load_item["timer"] >= fire_rate:
			eject_enemy(load_item)
			blend_load.remove_at(i)

func eject_enemy(enemy_data):

	var enemy = enemy_data["enemy"]
	
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
		tween.tween_property(sprite, "position", Vector2.ZERO, 0.5)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	
		# Wait for the tween to finish
		await tween.finished

	if is_instance_valid(enemy):
		var damage_mult: float = 1.0
		enemy.set_trapped(false)
		if enemy.category == "food":
			damage_mult = 2
		if enemy.take_damage(damage * damage_mult):
			# TODO: Enemy died from blender, add smoothie
			pass

func _update_stats(path_id, tier):
	if path_id == 1:
		if tier == 1:
			add_attack_range(25)
		elif tier == 2:
			fire_rate *= 0.8
		elif tier == 3:
			throw_distance = -100

	elif path_id == 2:
		if tier == 1:
			damage += 1
		elif tier == 2:
			# burn_duration += 2.0 --- IGNORE ---
			pass
		elif tier == 3:
			capacity += 12
