extends CanvasLayer

# Define a "Signal" that we shout out when a player picks something
signal request_tower_placement(tower_scene, cost)

# Preload your tower scenes here
var washing_machine_scene = preload("res://towers/WashingMachine.tscn")

@onready var menu_control = $Background

func _ready():
	# Hide the menu when the game starts
	visible = false
	
	# Connect the button click
	# (Adjust path if your button is deeper in the tree)
	$Background/GridContainer/BtnWashingMachine.pressed.connect(_on_washer_clicked)

func _input(event):
	# Toggle menu with 'E'
	if event.is_action_pressed("interact"):
		toggle_menu()

func toggle_menu():
	visible = not visible
	
	# Optional: Pause the game while building?
	# get_tree().paused = visible 

func _on_washer_clicked():
	# Close the menu
	toggle_menu()
	
	# Shout "I want to build a washer!" to the Main Game
	# We pass the scene file and the cost
	emit_signal("request_tower_placement", washing_machine_scene, 100)
