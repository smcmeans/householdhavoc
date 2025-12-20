extends Node2D

var show_range_setup: bool = false
var attack_range: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw():
	if show_range_setup:
		# Draw a filled circle (transparent color)
		var position = Vector2.ZERO
		position.y -= 10

		draw_circle(position, attack_range, Color(0, 0, 0, 0.3))
		
		# Draw a border outline for better visibility
		draw_arc(position, attack_range, 0, TAU, 32, Color.WHITE, 2.0)

func update_range_visuals(new_range: int, is_visible: bool):
	attack_range = new_range
	show_range_setup = is_visible
	queue_redraw()