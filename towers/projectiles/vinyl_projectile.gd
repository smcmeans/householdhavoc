extends Projectile

var spin_time: float = 0.4

func apply_effect(enemy):
	super.apply_effect(enemy)
	# Apply a spinning effect to the enemy
	enemy.apply_status("spinning", spin_time)
