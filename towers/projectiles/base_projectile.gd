extends Area2D
class_name Projectile

# --- Common Stats ---
@export var lifetime: float = 3.0 # Failsafe: destroy after 3 seconds if it hits nothing
var speed: float = 400.0
var piercing: int = 1
var damage: int = 1
var direction: Vector2 = Vector2.RIGHT
var enemies_hit: Array[Enemy] = []

@onready var sprite = $Sprite2D 

func _ready():
	# 1. Setup the cleanup timer (prevents memory leaks from stray bullets)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	
	# 2. Connect collision
	area_entered.connect(_on_hit)
	body_entered.connect(_on_wall_hit)

func _physics_process(delta):
	var travel_distance = speed * delta
	
	# 1. RAYCAST CHECK (Anti-Tunneling)
	# Cast a ray from current position to where we WANT to be
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + (direction * travel_distance))
	
	# Set the mask to match your bullet (Layers 1 and 2/3)
	query.collision_mask = collision_mask 
	query.collide_with_areas = true # Hit enemies
	query.collide_with_bodies = true # Hit walls
	
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	
	if result:
		# We hit something mid-step
		global_position = result["position"] # Snap to impact point
		
		# Manually trigger the hit logic since we stopped early
		if result["collider"] is Area2D:
			_on_hit(result["collider"])
		elif result["collider"] is TileMap or result["collider"] is TileMapLayer or result["collider"] is StaticBody2D:
			_on_wall_hit(result["collider"])
			
	# Path is clear, move normally
	position += direction * travel_distance

# --- The Hit Logic ---
func _on_hit(area):
	# Get the parent (The Enemy Node)
	var enemy = area.get_parent()
	
	# Verify it is an enemy
	if enemy is Enemy and piercing > 0 and not enemy in enemies_hit:
		enemies_hit.append(enemy)

		apply_effect(enemy)
		piercing -= 1
		if piercing <= 0:
			queue_free() # Destroy bullet

# --- VIRTUAL FUNCTION: Override this for special ammo ---
func apply_effect(enemy):
	# Default behavior: Just deal damage
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)


func _on_wall_hit(_body):
	# Check if the body is actually a wall/environment
	# (Layer 1 is bit 0, so value 1)
	queue_free()
