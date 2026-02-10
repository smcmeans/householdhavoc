extends ProjectileTower

# TODO Add a check to open the door when enemies are about to enter the tower's range

@export var hanger_trapped_duration: float = 0.2

var bouncy_hangers: bool = false
var multiplicative_damage: bool = false
var is_door_open: bool = false

@onready var anim_player = $AnimationPlayer

@onready var animation_range = $AnimationRange/CollisionShape2D

func _ready():
	var circle = CircleShape2D.new()
	circle.radius = attack_range + 50 # Add some padding so the animation doesn't get cut off
	animation_range.shape = circle


	super()
	
	path_1_upgrades = {
		1: { "name": "More Hangers", "cost": 100, "icon": null, "description": "Increases hangers thrown by 1." },
		2: { "name": "Even More Hangers",    "cost": 200, "icon": null, "description": "Increases hangers thrown by 2." },
		3: { "name": "Bouncy Hangers",  "cost": 800,"icon": null, "description": "Hangers bounce to nearby enemies." }
	}

	path_2_upgrades = {
		1: { "name": "Pointy Hangers",   "cost": 100, "icon": null, "description": "+1 Damage." },
		2: { "name": "Sturdy Hangers",  "cost": 250, "icon": null, "description": "Traps enemies for longer" },
		3: { "name": "Powerful Hangers", "cost": 1200,"icon": null, "description": "Multiplies Hanger Damage and Massively Increases Range" }
	}

func _physics_process(delta):
	super(delta)

func is_turret_aimed() -> bool:
	return super.is_turret_aimed()
		

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
	
	# Add to World
	get_parent().add_child(hanger)
	start_recoil_shake()

func open_closet():
	is_door_open = true
	anim_player.play("open")

func close_closet():
	is_door_open = false
	anim_player.play("close")

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

func _on_animation_range_area_entered(area: Area2D) -> void:
	if not is_door_open:
		open_closet()

func _on_animation_range_area_exited(area: Area2D) -> void:
	if is_door_open and potential_targets.size() == 0: # Only close if we don't have another target
		close_closet()
