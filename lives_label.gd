extends Label

func _ready():
	text = "Lives: " + str(GameData.lives)
	
	GameData.lives_changed.connect(_on_lives_changed)

func _on_lives_changed(new_amount):
	text = "Lives: " + str(new_amount)