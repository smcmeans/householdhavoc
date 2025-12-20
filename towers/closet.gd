extends ProjectileTower

var is_door_open: bool = false

@onready var anim_player = $AnimationPlayer

func _physics_process(delta):
    # 1. Run Base Logic (Finds/Updates targets)
	super(delta)
    
    # 2. DOOR LOGIC
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
	#hanger.rotation = pivot.rotation # Rotate the sprite too
	
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