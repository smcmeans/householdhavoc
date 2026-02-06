extends WaveManager

@export var path_bedroom: Path2D
@export var path_kitchen: Path2D

var bedroom_enemies: Array
var kitchen_enemies: Array

@export var bedroom_timer: Timer
@export var kitchen_timer: Timer 

signal bedroom_portal_opened
signal kitchen_portal_opened
signal bedroom_portal_closed
signal kitchen_portal_closed

# Configure catalog here
# Format: "Name": { "scene": PreloadedScene, "cost": PointValue }
var bedroom_enemy_catalog = {
	"Sock": {
		"scene": preload("res://enemies/Sock.tscn"),
		"cost": 1,
		"wave": 1
	},
	"Pants": {
		"scene": preload("res://enemies/Pants.tscn"),
		"cost": 5,
		"wave": 2
	},
	"Shirt": {
		"scene": preload("res://enemies/Shirt.tscn"),
		"cost": 8,
		"wave": 5
	},
	"Shoes": {
		"scene": preload("res://enemies/Shoes.tscn"),
		"cost": 12,
		"wave": 10
	},
	"Glasses": {
		"scene": preload("res://enemies/Glasses.tscn"),
		"cost": 5,
		"wave": 13

	},
	"Hat": {
		"scene": preload("res://enemies/Hat.tscn"),
		"cost": 25,
		"wave": 15
	},
}

var bedroom_boss_catalog = {
	"Outfit": {
		"scene": preload("res://enemies/Outfit.tscn"),
		"cost": 1,
		"wave": 10
	},
	"BedMonster": {
		"scene": preload("res://enemies/BedMonster.tscn"),
		"cost": 2,
		"wave": 20
	},
}

var kitchen_enemy_catalog = {
	"Spoon": {
		"scene": preload("res://enemies/Spoon.tscn"),
		"cost": 10,
		"wave": 20
	},
	"Fork": {
		"scene": preload("res://enemies/Fork.tscn"),
		"cost": 10,
		"wave": 15
	},
	"Apple": {
		"scene": preload("res://enemies/Apple.tscn"),
		"cost": 5,
		"wave": 10
	},
	"Banana": {
		"scene": preload("res://enemies/Banana.tscn"),
		"cost": 5,
		"wave": 15
	},
}

var kitchen_boss_catalog = {
	"Spork": {
		"scene": preload("res://enemies/Spork.tscn"),
		"cost": 1,
		"wave": 0
	},
	"Sandwich": {
		"scene": preload("res://enemies/Sandwich.tscn"),
		"cost": 2,
		"wave": 20
	},
}

func start_next_wave():
	print("Default wave_manager start_next_wave called. Implement in derived class.")

	print("--- Starting Wave ", GameData.current_round, " ---")

	# Calculate Budget (Formula: Wave 1 = 10, Wave 2 = 15, etc.)
	var budget = GameData.current_round * 5
	print("Wave Budget: ", budget)
	
	# Bedroom
	rooms_finished["bedroom"] = false
	if super.is_boss_round():
		bedroom_enemies = super.create_boss_wave(GameData.current_round, bedroom_boss_catalog)
	else:
		bedroom_enemies = super.generate_wave_queue(budget, bedroom_enemy_catalog)
	emit_signal("bedroom_portal_opened")
	bedroom_timer.start(0.5)
	
	# Kitchen
	if GameData.current_round > 10:
		rooms_finished["kitchen"] = false
		emit_signal("kitchen_portal_opened")
		if super.is_boss_round():
			kitchen_enemies = super.create_boss_wave(GameData.current_round, kitchen_boss_catalog)
		else:
			kitchen_enemies = super.generate_wave_queue(budget, kitchen_enemy_catalog)
		kitchen_timer.start(0.5)

func _on_bedroom_timer_timeout():
	super._spawn_enemy_on_path(bedroom_enemies, path_bedroom, bedroom_timer, "bedroom", "bedroom_portal_closed")

func _on_kitchen_timer_timeout():
	super._spawn_enemy_on_path(kitchen_enemies, path_kitchen, kitchen_timer, "kitchen", "kitchen_portal_closed")