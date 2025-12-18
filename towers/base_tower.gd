extends Node2D
class_name Tower

# --- Stats we want to modify in the Inspector ---
@export_category("Tower Stats")
@export var damage: int = 1
@export var attack_range: float = 250.0
@export var fire_rate: float = 1.0 # Seconds between shots
@export var build_cost: int = 100
@export var show_range_setup: bool = false # Debug toggle

# --- State Variables ---
var current_target: Enemy = null
var potential_targets: Array[Enemy] = []
var is_ready_to_fire: bool = true

# --- Nodes ---
@onready var detection_shape = $DetectionRange/CollisionShape2D
@onready var reload_timer = $ReloadTimer

func _ready():
    # 1. Apply range to the collision shape physically
    var circle = CircleShape2D.new()
    circle.radius = attack_range
    detection_shape.shape = circle
    
    # 2. Setup Timer
    reload_timer.wait_time = fire_rate
    reload_timer.one_shot = true # We will restart it manually after firing
    
    # 3. Connect Signals
    # Note: We connect these to the PARENT script functions defined below

func _physics_process(delta):
    update_target()
    
    # If we have a target and the gun is loaded... FIRE!
    if current_target != null and is_ready_to_fire and is_turret_aimed():
        fire()
        start_reload()

# --- Logic ---

func update_target():
    # If our current target died or escaped, forget them
    if not is_instance_valid(current_target):
        current_target = null
    
    # If we have no target, pick the first one in our list
    if current_target == null and potential_targets.size() > 0:
        current_target = potential_targets[0]
        # (Later, you can add logic here to pick "Strongest" or "Closest to Exit")

func start_reload():
    is_ready_to_fire = false
    reload_timer.start()
    await reload_timer.timeout # Wait for the timer to finish
    is_ready_to_fire = true

# --- VIRTUAL FUNCTION (To be overridden) ---
# This function does nothing here. The Washing Machine will "overwrite" this.
func fire():
    pass 

# --- Signal Handling ---
func _on_detection_range_area_entered(area):
    # The 'area' is the Hitbox. The Enemy script is on the Hitbox's parent.
    var enemy = area.get_parent()
    
    # Check if the parent is actually an Enemy (using the class_name we set up)
    if enemy is Enemy:
        potential_targets.append(enemy)
        print("Target Acquired: ", enemy.name)

func _on_detection_range_area_exited(area):
    var enemy = area.get_parent()
    
    if enemy in potential_targets:
        potential_targets.erase(enemy)
        if enemy == current_target:
            current_target = null

# VIRTUAL FUNCTION: Child classes can override this to require aiming
func is_turret_aimed():
    return true

func _draw():
    # Only draw if we are hovering, placing, or debugging
    if show_range_setup:
        # Draw a filled circle (transparent color)
        # Color(Red, Green, Blue, Alpha/Transparency)
        draw_circle(Vector2.ZERO, attack_range, Color(0, 0, 0, 0.3))
        
        # Optional: Draw a border outline for better visibility
        draw_arc(Vector2.ZERO, attack_range, 0, TAU, 32, Color.WHITE, 2.0)

# Function to toggle this on/off from other scripts
func set_range_visible(is_visible: bool):
    show_range_setup = is_visible
    queue_redraw() # Tells Godot "The visuals changed, run _draw() again!"

func _on_click_area_mouse_entered():
    # Show range when mouse is over the tower
    set_range_visible(true)

func _on_click_area_mouse_exited():
    # Hide range when mouse leaves
    set_range_visible(false)
