extends ProjectileTower

@export var burst_amount: int = 3
@export var spread_angle_degrees: float = 30.0

func fire():
    # 1. Convert spread to radians for math
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
        var water = create_projectile() 
    
        # Calculate the specific offset for this bullet index 'i'
        var current_offset = start_angle + (i * angle_step)
        
        # Add that offset to the Pivot's current rotation
        var final_angle = pivot.rotation + current_offset
        
        # Apply direction
        water.direction = Vector2.RIGHT.rotated(final_angle)
        water.rotation = final_angle # Rotate sprite too
        
        # Add to scene
        get_tree().root.add_child(water)
	
	