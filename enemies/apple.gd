extends Enemy

@onready var anim_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

var last_position: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

	last_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if is_trapped:
		# TODO: Add shivering animation or effect
		return
	else:
		if anim_player.current_animation != "walk":
			anim_player.play("walk")
	
	# Flip sprite based on movement direction
	var movement_vector = global_position - last_position
	if abs(movement_vector.x) >= 0.1:
		sprite_2d.flip_h = movement_vector.x < 0
	last_position = global_position

	
