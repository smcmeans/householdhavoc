extends Character

@export var portal_scene: PackedScene
@export var potion_scene: PackedScene

@export var throw_range: float = 250.0

var portal_positions: Array[Vector2]
var current_portal_index: bool = false
var portal_cooldown: float = 0.5
var can_use_portal: bool = true
var portals_in_scene: Array

var throwing: bool = false

func _ready():
	portal_positions = []

func _physics_process(delta):
	if throwing:
		if anim_player.current_animation == "walk":
			anim_player.play("RESET")


		var mouse_pos = get_global_mouse_position()
		var direction = global_position.direction_to(mouse_pos)
		var distance = global_position.distance_to(mouse_pos)

		
		if distance > throw_range:
			distance = throw_range
			mouse_pos = global_position + direction * throw_range

		# Play throw animation
		#$AnimationPlayer.play("throw_potion")
		#await $AnimationPlayer.animation_finished

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			get_parent().add_child(create_potion(mouse_pos))
			throwing = false
			set_range_visible(false)

		if Input.is_action_just_pressed("primary_ability"):
			throwing = false
			set_range_visible(false)
		return # Can't move while throwing

	if Input.is_action_just_pressed("primary_ability"):
		# Probably should add a cooldown here
		set_range_visible(true)
		throwing = true

	use_portal()
	super._physics_process(delta)

func set_range_visible(is_visible):
	$RangeIndicator.update_range_visuals(throw_range, is_visible)


func create_potion(target_position: Vector2) -> Node2D:
	var potion = potion_scene.instantiate()
	potion.global_position = global_position
	potion.target_position = target_position
	potion.potion_landed.connect(open_portal)
	return potion

func open_portal(target_position: Vector2):
	var portal = portal_scene.instantiate()
	portal.global_position = target_position

	if current_portal_index:
		# Change color to indicate second portal
		portal.modulate = Color(0.8, 0.5, 0.5)

	# Store portal position
	if portal_positions.size() < 2:
		portal_positions.append(target_position)
		portals_in_scene.append(portal)
	else:
		portal_positions[int(current_portal_index)] = target_position
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
