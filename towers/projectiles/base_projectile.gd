extends Area2D
class_name Projectile

# --- Common Stats ---
@export var lifetime: float = 3.0 # Failsafe: destroy after 3 seconds if it hits nothing
var speed: float = 400.0
var piercing: int = 1
var damage: int = 1
var direction: Vector2 = Vector2.RIGHT

@onready var sprite = $Sprite2D 

func _ready():
    # 1. Setup the cleanup timer (prevents memory leaks from stray bullets)
    get_tree().create_timer(lifetime).timeout.connect(queue_free)
    
    # 2. Connect collision
    area_entered.connect(_on_hit)

func _physics_process(delta):
    # Basic straight-line movement
    position += direction * speed * delta

# --- The Hit Logic ---
func _on_hit(area):
    # Get the parent (The Enemy Node)
    var enemy = area.get_parent()
    
    # Verify it is an enemy
    if enemy is Enemy and piercing > 0:
        apply_effect(enemy)
        piercing -= 1
        if piercing <= 0:
            queue_free() # Destroy bullet

# --- VIRTUAL FUNCTION: Override this for special ammo ---
func apply_effect(enemy):
    # Default behavior: Just deal damage
    if enemy.has_method("take_damage"):
        enemy.take_damage(damage)
