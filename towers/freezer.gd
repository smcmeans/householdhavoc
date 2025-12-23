extends ProjectileTower


@export var freeze_duration: float = 1.0
@export var burst_amount: int = 1

var spread_angle_degrees: float = 30.0

@onready var anim_player = $AnimationPlayer

func _ready():
	super()
	path_1_upgrades = {
		1: { "name": "Chilled Ice", "cost": 1, "icon": null, "description": "Ice can hit more enemies" },
		2: { "name": "Freeze Dried Ice",    "cost": 1, "icon": null, "description": "Ice can hit even more enemies" },
		3: { "name": "Nevermelt Ice",  "cost": 1,"icon": null, "description": "Ice can hit a ton of enemies" }
	}

	path_2_upgrades = {
		1: { "name": "Telescoping",   "cost": 1, "icon": null, "description": "Increases range" },
		2: { "name": "Extra cold",  "cost": 1, "icon": null, "description": "Freezes enemies for longer" },
		3: { "name": "Faulty Dispenser", "cost": 1,"icon": null, "description": "Shoots a ton of ice" }
	}

func _physics_process(delta):
	super(delta)

func fire():
	if burst_amount > 1:
		_fire_burst()
	else:
		_fire_single()

func _fire_burst():
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
		var ice_cube = create_projectile() 
	
		# Calculate the specific offset for this bullet index 'i'
		var current_offset = start_angle + (i * angle_step)
		
		# Add that offset to the Pivot's current rotation
		var final_angle = pivot.rotation + current_offset
		
		# Apply direction
		ice_cube.freeze_duration = freeze_duration
		ice_cube.direction = Vector2.RIGHT.rotated(final_angle)
		ice_cube.rotation = final_angle # Rotate sprite too
		get_tree().root.add_child(ice_cube)

func _fire_single():
	var ice_cube = create_projectile() 
	ice_cube.freeze_duration = freeze_duration
	ice_cube.direction = Vector2.RIGHT.rotated(pivot.rotation)
	get_tree().root.add_child(ice_cube)

func _update_stats(path_id, tier):
	if path_id == 1:
		if tier == 1:
			projectile_piercing += 1
		elif tier == 2:
			projectile_piercing += 2
		elif tier == 3:
			projectile_piercing += 50
	elif path_id == 2:
		if tier == 1:
			add_attack_range(30)
		elif tier == 2:
			freeze_duration += 1.0
		elif tier == 3:
			burst_amount = 10
			damage += 5
