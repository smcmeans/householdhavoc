extends Tower # We extend our custom class, not Node2D!

@export var cone_spread: float = 30.0

@onready var turret_head = $TurretHead
@onready var water_stream_area = $TurretHead/WaterStream
@onready var stream_visuals = $TurretHead/StreamVisuals
@onready var stream_collider = $TurretHead/WaterStream/CollisionPolygon2D

var enemies_in_stream: Dictionary = {}
var cleans_enemies: bool = false
# var raincloud_scene: PackedScene = preload("res://projectiles/Raincloud.tscn")
var storm_surge_added: bool = false
var shrinks_enemies: bool = false
var damp_duration: float = 5.0

# TODO: Add raincloud logic later

func _ready():
	super()
	if stream_visuals:
		stream_visuals.visible = false
	
	update_cone_shape()
		
	# We need to know when they enter/exit the STREAM specifically
	if not water_stream_area.area_entered.is_connected(_on_stream_area_entered):
		water_stream_area.area_entered.connect(_on_stream_area_entered)
	if not water_stream_area.area_exited.is_connected(_on_stream_area_exited):
		water_stream_area.area_exited.connect(_on_stream_area_exited)

	path_1_upgrades = {
		1: { "name": "Increased Water Pressure", "cost": 100, "icon": null, "description": "Increases range." },
		2: { "name": "Powerful Water", "cost": 150, "icon": null, "description": "Attacks 20% faster." },
		3: { "name": "Rainy Day Fund",  "cost": 800,"icon": null, "description": "Increases value of washed enemies" },
		4: { "name": "Storm Surge",  "cost": -1,"icon": null, "description": "Launches a raincloud at the nearest enemy."}
	}

	path_2_upgrades = {
		1: { "name": "Warm wash",   "cost": 200, "icon": null, "description": "+1 Damage and shrinks enemies" },
		2: { "name": "Air-Dry resistant",  "cost": 500, "icon": null, "description": "Applies damp for longer." },
		3: { "name": "Bad piping", "cost": 10,"icon": null, "description": "Sprays water everywhere." }
	}
	


func update_cone_shape():
	# Convert our spread angle to radians for math
	var angle_rad = deg_to_rad(cone_spread / 2.0)
	
	# Calculate the 3 points of the triangle
	var point_origin = Vector2.ZERO
	
	# Top Corner: Go out to 'attack_range', then rotate up
	var point_top = Vector2.RIGHT * attack_range
	point_top = point_top.rotated(-angle_rad)
	
	# Bottom Corner: Go out to 'attack_range', then rotate down
	var point_bottom = Vector2.RIGHT * attack_range
	point_bottom = point_bottom.rotated(angle_rad)
	
	# Build the Array of points
	var new_shape = PackedVector2Array([point_origin, point_top, point_bottom])
	
	# Apply to Hitbox
	stream_collider.polygon = new_shape
	
	# Apply to Visuals (so they match perfectly)
	if stream_visuals:
		stream_visuals.polygon = new_shape

# Special fire declared elsewhere
func fire():
	pass

# Override the parent check
func is_turret_aimed() -> bool:
	# Safety check: If we have no target, we definitely aren't aimed
	if current_target == null:
		return false
	
	# Calculate the direction to the enemy
	var direction_to_target = global_position.direction_to(current_target.global_position)
	
	# Get the direction the Turret Head is currently facing
	# (In Godot, the local X-axis (Right) is the "Forward" face of a 2D node)
	var current_facing = Vector2.RIGHT.rotated(turret_head.rotation)
	
	# Compare them using the Dot Product
	# If dot product is 1.0, they are perfectly aligned. 
	# If it's > 0.95, they are within about 18 degrees of each other.
	if current_facing.dot(direction_to_target) > 0.9:
		return true
	
	return false

func _physics_process(delta):
	super._physics_process(delta)
	
	# 1. Handle Visuals & Rotation (Existing Logic)
	if current_target != null:
		var direction = global_position.direction_to(current_target.global_position)
		turret_head.rotation = lerp_angle(turret_head.rotation, direction.angle(), 10 * delta)
		if stream_visuals: stream_visuals.visible = true
	else:
		if stream_visuals: stream_visuals.visible = false

	# 2. NEW: Handle Damage Over Time (DoT)
	# We loop through every enemy currently in the water
	for enemy in enemies_in_stream.keys():
		
		# Safety Check: Did the enemy die?
		if not is_instance_valid(enemy):
			enemies_in_stream.erase(enemy)
			continue
			
		# Add time to their personal counter
		enemies_in_stream[enemy] += delta
		
		# Hit them if enough time has passed
		if enemies_in_stream[enemy] >= fire_rate:
			hit_enemy(enemy)
			enemies_in_stream[enemy] = 0.0 # Reset counter

# --- Signal Functions ---

func _on_stream_area_entered(area):
	# Get the enemy logic script from the Hitbox parent
	var enemy = area.get_parent()
	
	if enemy is Enemy:
		# INSTANT HIT LOGIC
		hit_enemy(enemy)
		
		# Start tracking them for DoT
		# We set timer to 0.0 so they have to wait 1 second for the next hit
		enemies_in_stream[enemy] = 0.0

func _on_stream_area_exited(area):
	var enemy = area.get_parent()
	if enemy in enemies_in_stream:
		enemies_in_stream.erase(enemy)

# Helper function to keep code clean
func hit_enemy(enemy):
	enemy.take_damage(damage)
	enemy.apply_status("damp", damp_duration) 
	if cleans_enemies and not enemy.cleaned:
		enemy.cleaned = true
	if shrinks_enemies:
		enemy.apply_status("shrunken", damp_duration)
	print("Washed ", enemy.name)

func _update_stats(path_id, tier):
	if path_id == 1:
		if tier == 1:
			add_attack_range(25)
		elif tier == 2:
			fire_rate *= 0.8
		elif tier == 3:
			cleans_enemies = true
		elif tier == 4:
			storm_surge_added = true
	elif path_id == 2:
		if tier == 1:
			damage += 1
			shrinks_enemies = true
		elif tier == 2:
			damp_duration += 5.0
		elif tier == 3:
			cone_spread = 90.0 # Probably change this upgrade
			update_cone_shape()

func add_attack_range(amount: float):
	super.add_attack_range(amount)
	update_cone_shape()