extends Character

@export var portal_scene: PackedScene

var portal_positions: Array[Vector2]
var current_portal_index: bool = false
var portal_cooldown: float = 0.5
var can_use_portal: bool = true
var portals_in_scene: Array

func _ready():
	portal_positions = []

func _physics_process(delta):
	if Input.is_action_just_pressed("primary_ability"):
		# Probably should add a cooldown here
		open_portal()

	use_portal()
	super._physics_process(delta)

func open_portal():
	var portal = portal_scene.instantiate()
	portal.global_position = global_position

	if current_portal_index:
		# Change color to indicate second portal
		portal.modulate = Color(0.8, 0.5, 0.5)

	# Store portal position
	if portal_positions.size() < 2:
		portal_positions.append(global_position)
		portals_in_scene.append(portal)
	else:
		portal_positions[int(current_portal_index)] = global_position
		# Remove old portal from scene
		var old_portal = portals_in_scene[int(current_portal_index)]
		if is_instance_valid(old_portal):
			old_portal.queue_free()
		portals_in_scene[int(current_portal_index)] = portal
	current_portal_index = not current_portal_index

	portal.play("default")

	portal_timeout()
	get_parent().add_child(portal)

# Need to find a way to make this better for multiplayer
func use_portal():
	if portal_positions.size() < 2 || not can_use_portal:
		return # Not enough portals placed

	var distance = 10

	for i in range(2):
		if abs(portal_positions[i].x - global_position.x) < distance and abs(portal_positions[i].y - global_position.y) < distance:
			global_position = portal_positions[(i + 1) % 2]
			# Add cooldown to prevent immediate re-teleporting
			portal_timeout()
			break

func portal_timeout():
	can_use_portal = false
	await get_tree().create_timer(portal_cooldown).timeout
	can_use_portal = true