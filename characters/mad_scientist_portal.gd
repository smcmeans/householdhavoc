extends Node2D

var other_portal: Vector2


func set_other_portal_position(other_portal_position: Vector2):
	other_portal = other_portal_position

func _on_area_2d_body_exited(body: Node2D) -> void:
	#print("Area exited: " + str(body))
	if body is Character:
		# Check if teleporting
		if body.teleporting:
			body.teleporting = false # Reset teleporting state
			return

		body.can_teleport = true # Allow teleporting again once they leave the portal area

func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("Area entered: " + str(body))


	if body is Character and body.can_teleport and other_portal:
		body.can_teleport = false # Prevent immediate re-teleporting
		body.teleporting = true # Set teleporting state to prevent re-entry issues
		body.global_position = other_portal # Teleport to the other portal
