extends SubViewportContainer

# # Base resolution constants
# const BASE_WIDTH = 640
# const BASE_HEIGHT = 360

# const TARGET_SCALE = 2  

# func _ready():
#     # Listen for window resize events
#     get_tree().root.size_changed.connect(_update_scale)
    
#     # Call it once at startup to set the initial size
#     _update_scale()

# func _update_scale():
#     # Get the actual pixel size of the window/screen
#     var window_size = get_viewport().size
    
#     # Calculate how many times the width fits
#     var scale_x = floor(window_size.x / BASE_WIDTH)
#     # Calculate how many times the height fits
#     var scale_y = floor(window_size.y / BASE_HEIGHT)
    
#     # Take the smaller of the two to ensure it fits on screen
#     var final_scale = min(scale_x, scale_y) * TARGET_SCALE
    
#     # Safety check: Prevent scale from being 0 (invisible)
#     if final_scale < 1:
#         final_scale = TARGET_SCALE
        
#     # Apply the integer scale (e.g., 1, 2, 3, 4)
#     stretch_shrink = final_scale