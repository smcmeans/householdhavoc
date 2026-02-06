extends BaseMap

@export var BedroomPortal: Sprite2D
@export var KitchenPortal: Sprite2D

func _ready():
	super()
	
	map_wave_manager.bedroom_portal_opened.connect(_on_bedroom_portal_opened)
	map_wave_manager.bedroom_portal_closed.connect(_on_bedroom_portal_closed)
	map_wave_manager.kitchen_portal_opened.connect(_on_kitchen_portal_opened)
	map_wave_manager.kitchen_portal_closed.connect(_on_kitchen_portal_closed)

	BedroomPortal.visible = false
	KitchenPortal.visible = false

func _on_bedroom_portal_opened():
	BedroomPortal.visible = true
	var anim = BedroomPortal.get_parent().get_node("AnimationPlayer")
	anim.play("portal_swoosh")

func _on_bedroom_portal_closed():
	BedroomPortal.visible = false
	var anim = BedroomPortal.get_parent().get_node("AnimationPlayer")
	anim.play("RESET")

func _on_kitchen_portal_opened():
	KitchenPortal.visible = true
	var anim = KitchenPortal.get_parent().get_node("AnimationPlayer")
	anim.play("portal_swoosh")

func _on_kitchen_portal_closed():
	KitchenPortal.visible = false
	var anim = KitchenPortal.get_parent().get_node("AnimationPlayer")
	anim.play("RESET")

#func _on_kitchen_timer_timeout() -> void:
#	map_wave_manager._on_kitchen_timer_timeout()

#func _on_bedroom_timer_timeout() -> void:
#	map_wave_manager._on_bedroom_timer_timeout()
