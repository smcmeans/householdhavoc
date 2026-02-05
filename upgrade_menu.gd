extends Control

var current_tower = null

func _ready():
	visible = false

	$BtnClose.pressed.connect(_on_close_btn_pressed)
	$BtnSell.pressed.connect(_on_sell_btn_pressed)
	$HBoxContainer/Path1/BtnPath1.pressed.connect(_on_btn_path_1_pressed)
	$HBoxContainer/Path2/BtnPath2.pressed.connect(_on_btn_path_2_pressed)

func open_menu(tower):
	# If we already have a DIFFERENT tower selected, deselect it first
	if current_tower != null and current_tower != tower:
		current_tower.deselect_tower()
	
	# Set the new tower
	current_tower = tower
	
	# Show the menu and refresh data
	visible = true
	refresh_ui()

func close_menu():
	visible = false
	
	# Hide the range on the tower we are leaving
	if current_tower != null:
		current_tower.deselect_tower()
		current_tower = null

# Connect your Close Button to this!
func _on_close_btn_pressed():
	close_menu()

func _on_sell_btn_pressed():
	if current_tower == null: return

	# Add money to player
	GameData.add_money(current_tower.sell_value)

	# Remove tower from scene
	current_tower.queue_free()

func refresh_ui():
	if current_tower == null: return
	
	# --- UPDATE PATH 1 BUTTON ---
	var next_t1 = current_tower.path_1_tier + 1
	if current_tower.path_1_upgrades.has(next_t1):
		var data = current_tower.path_1_upgrades[next_t1]
		$HBoxContainer/Path1/Path1Name.text = data["name"]
		$HBoxContainer/Path1/Path1Cost.text = "$" + str(data["cost"])
		$HBoxContainer/Path1/Path1Description.visible = true
		$HBoxContainer/Path1/Path1Description.text = data["description"]
		$HBoxContainer/Path1/BtnPath1.disabled = false
		$HBoxContainer/Path1/BtnPath1.text = "Buy"
	else:
		$HBoxContainer/Path1/Path1Name.text = "MAXED"
		$HBoxContainer/Path1/Path1Cost.text = "---"
		$HBoxContainer/Path1/Path1Description.visible = false
		$HBoxContainer/Path1/BtnPath1.disabled = true
		$HBoxContainer/Path1/BtnPath1.text = "Done"

	# --- UPDATE PATH 2 BUTTON ---
	var next_t2 = current_tower.path_2_tier + 1
	if current_tower.path_2_upgrades.has(next_t2):
		var data = current_tower.path_2_upgrades[next_t2]
		$HBoxContainer/Path2/Path2Name.text = data["name"]
		$HBoxContainer/Path2/Path2Cost.text = "$" + str(data["cost"])
		$HBoxContainer/Path2/Path2Description.visible = true
		$HBoxContainer/Path2/Path2Description.text = data["description"]
		$HBoxContainer/Path2/BtnPath2.disabled = false
		$HBoxContainer/Path2/BtnPath2.text = "Buy"
	else:
		$HBoxContainer/Path2/Path2Name.text = "MAXED"
		$HBoxContainer/Path2/Path2Cost.text = "---"
		$HBoxContainer/Path2/Path2Description.visible = false
		$HBoxContainer/Path2/BtnPath2.disabled = true
		$HBoxContainer/Path2/BtnPath2.text = "Done"
func _on_btn_path_1_pressed():
	if current_tower:
		current_tower.apply_upgrade(1)
		refresh_ui() # Refresh to show the next upgrade

func _on_btn_path_2_pressed():
	if current_tower:
		current_tower.apply_upgrade(2)
		refresh_ui()
