extends Node2D

var other_portal_position: Vector2


func set_other_portal_position(portal_position: Vector2):
	other_portal_position = portal_position

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Area entered: " + str(area))

	var player = area.get_parent()
	if player is Character and player.can_teleport:
		player.can_teleport = false # Prevent immediate re-teleporting
		player.global_position = other_portal_position # Teleport to the other portal
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	var player = area.get_parent()
	if player is Character:
		player.can_teleport = true # Allow teleporting again once they leave the portal area