extends Projectile

var push_time = 0

func apply_effect(enemy):

	enemy.apply_status("blown_away", push_time)
