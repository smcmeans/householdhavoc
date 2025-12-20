extends Projectile

@export var damp_duration: int = 5

func apply_effect(enemy):
	super.apply_effect(enemy)
	enemy.apply_status("damp", damp_duration)