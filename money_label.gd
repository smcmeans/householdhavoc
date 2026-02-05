extends Label

func _ready():
	# Update text at start
	text = "Money: " + str(GameData.money)
	
	# Listen for changes from the Bank
	GameData.money_changed.connect(_on_money_changed)

func _on_money_changed(new_amount):
	text = "Money: " + str(new_amount)
