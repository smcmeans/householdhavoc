extends Projectile


func _physics_process(delta):
    super(delta) 
    
    # Add spinning
    sprite.rotation += 10.0 * delta

func apply_effect(enemy):
    # Deal damage
    super.apply_effect(enemy)

    enemy.apply_status("hanger_trapped", 0.2)