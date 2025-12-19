extends Enemy

@onready var anim_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if is_trapped:
		# TODO: Add shivering animation or effect
		return
	else:
		if anim_player.current_animation != "walk":
			anim_player.play("walk")
