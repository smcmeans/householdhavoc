extends CharacterBody2D

@export var speed = 100.0
@export var attack_damage: int = 2
@export var attack_cooldown: float = 0.5

@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D

@onready var slash_sprite = $AtackPivot/SlashSprite

var can_attack: bool = true

func _ready():
	slash_sprite.visible = false

func _physics_process(delta):
	
	if anim_player.current_animation == "attack":
		
		return

	# Get input direction (WASD or Arrows)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	$AtackPivot.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("ui_attack") and can_attack:
		perform_slash_attack()
		return

	if direction:
		velocity = direction * speed
		
		# 2. PLAY WALK ANIMATION
		# We check 'current_animation' so we don't restart it every single frame
		if anim_player.current_animation != "walk":
			anim_player.play("walk")
			
		# 3. FLIP THE SPRITE (Left/Right)
		if direction.x < 0:
			sprite.flip_h = true  # Face Left
		elif direction.x > 0:
			sprite.flip_h = false # Face Right
			
	else:
		velocity = Vector2.ZERO
		
		# 4. STOP ANIMATION (When standing still)
		# "RESET" is the default pose Godot creates automatically
		if anim_player.current_animation != "RESET" && anim_player.current_animation != "attack":
			anim_player.play("RESET")

	move_and_slide()

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
	$AnimationPlayer.play("attack")
	await $AnimationPlayer.animation_finished
	slash_sprite.visible = false
	$AnimationPlayer.play("RESET")

	# COOLDOWN: Wait before attacking again
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
