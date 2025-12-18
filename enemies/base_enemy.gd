extends PathFollow2D
class_name Enemy

@export var move_speed: float = 150.0
@export var max_health: int = 5
@export var gold_reward: int = 5

@onready var health_bar = $ProgressBar

@onready var sprite = $Sprite2D
var default_color = Color(1, 1, 1, 1)
 
var current_health: int
var active_statuses: Dictionary = {}

func _ready():
    current_health = max_health
    
    # SETUP THE BAR
    health_bar.max_value = max_health
    health_bar.value = current_health
    
    # Optional: Hide the bar if health is full? 
    # health_bar.visible = false 
    
    loop = false 

func _physics_process(delta):
    progress += move_speed * delta * status_speed_effect()
    if progress_ratio >= 1.0:
        escape_house()
    handle_statuses(delta)

func status_speed_effect():
    var speed_mult = 1
    if has_status("damp"):
        speed_mult *= 0.8
    if has_status("frozen"):
        speed_mult = 0
    return speed_mult


func take_damage(amount: int):
    current_health -= amount
    
    # UPDATE THE BAR
    health_bar.value = current_health
    # health_bar.visible = true
    
    if current_health <= 0:
        die()

func die():
    print("Enemy died!")
    queue_free()

func escape_house():
    queue_free()

func handle_statuses(delta):
    # We get the keys first so we can safely remove items while looping
    var current_effects = active_statuses.keys()
    
    for effect in current_effects:
        # Decrease the timer
        active_statuses[effect] -= delta
        
        # If time runs out, remove the status
        if active_statuses[effect] <= 0:
            remove_status(effect)

func apply_status(effect_name: String, duration: float):
    # Add or refresh the status
    active_statuses[effect_name] = duration
    
    # Update visuals immediately
    update_status_visuals()
    print(name + " applied status: " + effect_name)

func remove_status(effect_name: String):
    if active_statuses.has(effect_name):
        active_statuses.erase(effect_name)
        update_status_visuals()
        print(name + " removed status: " + effect_name)

# Helper for Towers to check
func has_status(effect_name: String) -> bool:
    return active_statuses.has(effect_name)

# Handle Color Mixing (Priorities)
func update_status_visuals():
    # Reset to normal first
    sprite.modulate = default_color
    
    # Check priorities (Last one applied wins, or define a hierarchy)
    if has_status("frozen"):
        sprite.modulate = Color(0.5, 1, 1) # Cyan
    elif has_status("damp"):
        sprite.modulate = Color(0.7, 0.7, 1.5) # Blue tint
    elif has_status("burning"):
        sprite.modulate = Color(1, 0.5, 0.5) # Red tint