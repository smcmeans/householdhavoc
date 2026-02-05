extends Node2D

signal potion_landed(target_pos)

var speed: float = 100.0  # Pixels per second
var arc_height: float # How high (in pixels) the potion goes

var target_position: Vector2
var start_position: Vector2
var total_time: float = 0.0
var current_time: float = 0.0
var splash_radius: float = 10.0

@onready var drop_shadow = $DropShadow

func _ready():
	start_position = global_position
	
	# Calculate how long the flight should take based on speed
	var distance = start_position.distance_to(target_position)
	if distance > 0:
		total_time = distance / speed
		arc_height = distance / 3  # Arc height proportional to distance
	else:
		# If spawning on top of target, land instantly
		land()

func _physics_process(delta):
	current_time += delta
	
	# Calculate progress (0.0 is start, 1.0 is end)
	var t = current_time / total_time
	
	# If we reached 100%, land
	if t >= 1.0:
		land()
		return

	# Calculate the Base Position (Linear movement from A to B)
	var ground_position = start_position.lerp(target_position, t)
	
	# Calculate Height (The Arc)
	# -4 * t * (t - 1) creates a 0 -> 1 -> 0 curve
	var height_offset = arc_height * -4 * t * (t - 1)
	
	# Apply visual position
	global_position = ground_position - Vector2(0, height_offset)
	drop_shadow.global_position = ground_position

func land():

	# TODO Add potion plash effect/damage here

	# Snap to exact target to prevent floating point errors
	global_position = target_position 
	potion_landed.emit(target_position)
	queue_free()
