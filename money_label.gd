extends Label

func _ready():
	# 1. Update text at start
	text = "Money: " + str(GameData.money)
	
	# 2. Listen for changes from the Bank
	GameData.money_changed.connect(_on_money_changed)

func _on_money_changed(new_amount):
	text = "Money: " + str(new_amount)
