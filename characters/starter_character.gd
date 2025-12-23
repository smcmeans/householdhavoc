extends Character

@export var attack_damage: int = 3
@export var attack_cooldown: float = 0.5
@export var sprint_multiplier: float = 1.5

@onready var slash_sprite = $AtackPivot/SlashSprite

var can_attack: bool = true
var sprinting: bool = false
var base_speed: float

func _ready():
	slash_sprite.visible = false
	base_speed = speed

func _physics_process(delta):
	if Input.is_action_just_pressed("secondary_ability"):
		set_sprinting(true)

	if Input.is_action_just_released("secondary_ability"):
		set_sprinting(false)

	if anim_player.current_animation == "StarterCharacter/attack":
		return
	$AtackPivot.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("primary_ability") and can_attack:
		perform_slash_attack()
		return
	super._physics_process(delta)

func perform_slash_attack():
	
	can_attack = false
	
	# Get everyone in range
	var targets = $AtackPivot/AttackArea.get_overlapping_areas()
	
	for area in targets:
		# Get the Enemy node (Area's parent)
		var enemy = area.get_parent()

		print("Hitting enemy: " + str(enemy))
		
		# Verify it's a valid enemy
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			enemy.take_damage(attack_damage)
			 # Optional: Add knockback here!
	
	# Play animation
	slash_sprite.visible = true
	$AnimationPlayer.play("StarterCharacter/attack")
	await $AnimationPlayer.animation_finished
	slash_sprite.visible = false
	$AnimationPlayer.play("RESET")

	# COOLDOWN: Wait before attacking again
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func set_sprinting(is_sprinting: bool) -> void:
	sprinting = is_sprinting
	if sprinting:
		speed = base_speed * sprint_multiplier
	else:
		speed = base_speed
