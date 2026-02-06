extends Button

@onready var wave_manager: Node
#get_tree().current_scene.get_node("wave_manager")

func _ready():

	# Find the wave manager
	for node in get_tree().get_first_node_in_group("map").get_children():
		if node.is_in_group("wave_manager"):
			wave_manager = node
			break

	wave_manager.enable_wave_button.connect(_on_wave_ended)



func _pressed():
	
	GameData.current_round += 1
	$"../RoundLabel".update_round()
	# Find the wave_manager and tell it to go
	wave_manager.start_next_wave() 
	# Disable button so we don't spam it
	disabled = true

func _on_wave_ended():
	disabled = false
