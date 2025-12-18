extends Button

@onready var wave_manager = get_tree().current_scene.get_node("WaveManager")

func _ready():
	# CONNECT THE SIGNAL
	# Translation: "When wave_manager shouts 'enable_wave_button', run my function '_on_wave_ended'"
	wave_manager.enable_wave_button.connect(_on_wave_ended)

func _pressed():
	# Find the WaveManager and tell it to go
	# (Adjust the path if your WaveManager is somewhere else)
	$"../../WaveManager".start_next_wave() 
	# Disable button so we don't spam it?
	disabled = true

func _on_wave_ended():
	disabled = false
