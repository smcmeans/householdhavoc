extends Label

func _ready():
	update_round()
	
func update_round():
	text = "Round: " + str(GameData.current_round)
	


