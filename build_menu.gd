extends CanvasLayer

# TODO: Find a way to get the price from the base_tower

# Define a "Signal" that we shout out when a player picks something
signal request_tower_placement(tower_scene, cost)

# Preload your tower scenes here
var washing_machine_scene = preload("res://towers/WashingMachine.tscn")
var dryer_scene = preload("res://towers/Dryer.tscn")
var closet_scene = preload("res://towers/Closet.tscn")
var sink_scene = preload("res://towers/Sink.tscn")
var fan_scene = preload("res://towers/Fan.tscn")
var vinyl_player_scene = preload("res://towers/VinylPlayer.tscn")
var freezer_scene = preload("res://towers/Freezer.tscn")

func _ready():
	# Hide the menu when the game starts
	visible = false
	
	# Connect the button click
	$GridContainer/BtnWashingMachine.pressed.connect(_on_washer_clicked)
	$GridContainer/BtnDryer.pressed.connect(_on_dryer_clicked)
	$GridContainer/BtnCloset.pressed.connect(_on_closet_clicked)
	$GridContainer/BtnSink.pressed.connect(_on_sink_clicked)
	$GridContainer/BtnFan.pressed.connect(_on_fan_clicked)
	$GridContainer/BtnVinylPlayer.pressed.connect(_on_vinyl_player_clicked)
	$GridContainer/BtnFreezer.pressed.connect(_on_freezer_clicked)

func _input(event):
	if event.is_action_pressed("toggle_build_menu"):
		toggle_menu()

func toggle_menu():
	visible = not visible
	

func _on_washer_clicked():
	build_tower(washing_machine_scene, 100)

func _on_dryer_clicked():
	build_tower(dryer_scene, 200)

func _on_closet_clicked():
	build_tower(closet_scene, 100)

func _on_sink_clicked():
	build_tower(sink_scene, 150)

func _on_fan_clicked():
	build_tower(fan_scene, 100)

func _on_vinyl_player_clicked():
	build_tower(vinyl_player_scene, 200)

func _on_freezer_clicked():
	build_tower(freezer_scene, 300)

func build_tower(tower_scene: Resource, cost: int):
	if GameData.money < cost:
		print("Not enough money to build tower!")
		return
	toggle_menu()

	emit_signal("request_tower_placement", tower_scene, cost)
