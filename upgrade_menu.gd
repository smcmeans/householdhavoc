extends Control

var current_tower = null

func open_menu(tower):
    current_tower = tower
    visible = true
    refresh_ui()

func refresh_ui():
    if current_tower == null: return
    
    # --- UPDATE PATH 1 BUTTON ---
    var next_t1 = current_tower.path_1_tier + 1
    if current_tower.path_1_upgrades.has(next_t1):
        var data = current_tower.path_1_upgrades[next_t1]
        $HBox/LeftCol/Path1Name.text = data["name"]
        $HBox/LeftCol/Path1Cost.text = "$" + str(data["cost"])
        $HBox/LeftCol/BtnPath1.disabled = false
        $HBox/LeftCol/BtnPath1.text = "Buy"
    else:
        $HBox/LeftCol/Path1Name.text = "MAXED"
        $HBox/LeftCol/BtnPath1.disabled = true

    # --- UPDATE PATH 2 BUTTON ---
    var next_t2 = current_tower.path_2_tier + 1
    if current_tower.path_2_upgrades.has(next_t2):
        var data = current_tower.path_2_upgrades[next_t2]
        $HBox/RightCol/Path2Name.text = data["name"]
        $HBox/RightCol/Path2Cost.text = "$" + str(data["cost"])
        $HBox/RightCol/BtnPath2.disabled = false
    else:
        $HBox/RightCol/Path2Name.text = "MAXED"
        $HBox/RightCol/BtnPath2.disabled = true

# Connected signals from the buttons
func _on_btn_path_1_pressed():
    if current_tower:
        current_tower.apply_upgrade(1)
        refresh_ui() # Refresh to show the next upgrade

func _on_btn_path_2_pressed():
    if current_tower:
        current_tower.apply_upgrade(2)
        refresh_ui()