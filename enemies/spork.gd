extends Enemy

@onready var fork_scene = preload("res://enemies/Fork.tscn")
@onready var spoon_scene = preload("res://enemies/Spoon.tscn")

func die():
	# Play death animation or effects here
	@warning_ignore("integer_division")
	for i in range(GameData.current_round / 10):
		var utensil_instance
		if i % 2 == 0:
			utensil_instance = fork_scene.instantiate()
		else:
			utensil_instance = spoon_scene.instantiate()
		get_parent().add_child(utensil_instance)
		utensil_instance.set_boss_enemy()
		utensil_instance.progress = progress
	queue_free()
