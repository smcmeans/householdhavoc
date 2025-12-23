extends Projectile

@export var freeze_duration: float = 1.0

func apply_effect(enemy):

	super.apply_effect(enemy)
	enemy.apply_status("frozen", freeze_duration)
