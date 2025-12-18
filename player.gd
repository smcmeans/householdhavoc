extends CharacterBody2D

@export var speed = 100.0
# 1. GET THE ANIMATION PLAYER
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D

func _physics_process(delta):
    # Get input direction (WASD or Arrows)
    var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    if direction:
        velocity = direction * speed
        
        # 2. PLAY WALK ANIMATION
        # We check 'current_animation' so we don't restart it every single frame
        if anim_player.current_animation != "walk":
            anim_player.play("walk")
            
        # 3. FLIP THE SPRITE (Left/Right)
        if direction.x < 0:
            sprite.flip_h = true  # Face Left
        elif direction.x > 0:
            sprite.flip_h = false # Face Right
            
    else:
        velocity = Vector2.ZERO
        
        # 4. STOP ANIMATION (When standing still)
        # "RESET" is the default pose Godot creates automatically
        if anim_player.current_animation != "RESET":
            anim_player.play("RESET")

    move_and_slide()