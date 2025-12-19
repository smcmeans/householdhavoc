extends CanvasLayer

# Define a "Signal" that we shout out when a player picks something
signal request_tower_placement(tower_scene, cost)

# Preload your tower scenes here
var washing_machine_scene = preload("res://towers/WashingMachine.tscn")
var dryer_scene = preload("res://towers/Dryer.tscn")

@onready var menu_control = $Background

func _ready():
	# Hide the menu when the game starts
	visible = false
	
	# Connect the button click
	# (Adjust path if your button is deeper in the tree)
	$Background/GridContainer/BtnWashingMachine.pressed.connect(_on_washer_clicked)
	$Background/GridContainer/BtnDryer.pressed.connect(_on_dryer_clicked)

func _input(event):
	if event.is_action_pressed("toggle_build_menu"):
		toggle_menu()

func toggle_menu():
	visible = not visible
	

func _on_washer_clicked():
	var cost = 100

	if GameData.money < cost:
		print("Not enough money to build Washing Machine!")
		return

	# Close the menu
	toggle_menu()
	
	# Shout "I want to build a washer!" to the Main Game
	# We pass the scene file and the cost
	emit_signal("request_tower_placement", washing_machine_scene, cost)

func _on_dryer_clicked():
	var cost = 200
	if GameData.money < cost:
		print("Not enough money to build Dryer!")
		return

	toggle_menu()

	emit_signal("request_tower_placement", dryer_scene, cost)
