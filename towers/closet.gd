extends ProjectileTower


@export var hanger_trapped_duration: float = 0.2

var bouncy_hangers: bool = false
var multiplicative_damage: bool = false
var is_door_open: bool = false

@onready var anim_player = $AnimationPlayer

func _ready():
	super()
	path_1_upgrades = {
		1: { "name": "More Hangers", "cost": 1, "icon": null, "description": "Increases hangers thrown by 1." },
		2: { "name": "Even More Hangers",    "cost": 1, "icon": null, "description": "Increases hangers thrown by 2." },
		3: { "name": "Bouncy Hangers",  "cost": 1,"icon": null, "description": "Hangers bounce to nearby enemies." }
	}

	path_2_upgrades = {
		1: { "name": "Pointy Hangers",   "cost": 1, "icon": null, "description": "+1 Damage." },
		2: { "name": "Sturdy Hangers",  "cost": 1, "icon": null, "description": "Traps enemies for longer" },
		3: { "name": "Powerful Hangers", "cost": 1,"icon": null, "description": "Multiplies Hanger Damage and Massively Increases Range" }
	}

func _physics_process(delta):
	super(delta)
	
	# Case A: We have a target, but the door is closed -> OPEN IT
	if current_target != null and not is_door_open:
		open_closet()
		
	# Case B: We lost the target, but the door is open -> CLOSE IT
	elif current_target == null and is_door_open:
		close_closet()

func is_turret_aimed() -> bool:
	return super.is_turret_aimed() and not (anim_player.current_animation == "open" or anim_player.is_playing())
		

func fire():
	if projectile_scene == null:
		print("Error: No projectile scene assigned to Closet Tower!")
		return
	
	var hanger = create_projectile()

	# Calculate direction based on where the pivot is facing
	hanger.direction = Vector2.RIGHT.rotated(pivot.rotation)
	# Set projectile properties
	hanger.bouncy_hangers = bouncy_hangers
	hanger.multiplicative_damage = multiplicative_damage
	hanger.hanger_trapped_duration = hanger_trapped_duration
	
	# D. Add to World (CRITICAL STEP)
	get_tree().root.add_child(hanger)
	start_recoil_shake()

func open_closet():
	is_door_open = true
	anim_player.play("open")

func close_closet():
	is_door_open = false
	anim_player.play("close")

func start_recoil_shake():
	# 1. Get the sprite (Make sure this path is correct for your scene!)
	var sprite = $Sprite2D
	
	# 2. Create a Tween
	var tween = create_tween()
	
	# 3. Define the Shake (Kick back -> Return)
	# Since the sprite is inside the Pivot, moving X negative kicks it "backwards"
	# regardless of which way the tower is rotating.
	
	# Step A: Kick back 10 pixels instantly (0.05 seconds)
	tween.tween_property(sprite, "position:x", -5.0, 0.02)
	
	# Step B: Return to center (0.0) slightly slower (0.1 seconds)
	tween.tween_property(sprite, "position:x", 0.0, 0.1)

func _update_stats(path_id, tier):
	if path_id == 1:
		if tier == 1:
			projectile_piercing += 1
		elif tier == 2:
			projectile_piercing += 2
		elif tier == 3:
			bouncy_hangers = true
			add_attack_range(50)
	elif path_id == 2:
		if tier == 1:
			damage += 1
			add_attack_range(20)
		elif tier == 2:
			hanger_trapped_duration += 0.2
			damage += 3
		elif tier == 3:
			damage += 5
			multiplicative_damage = true
			add_attack_range(100)
