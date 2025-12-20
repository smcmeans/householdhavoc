extends Node

# Signal to tell the UI to update whenever money changes
signal money_changed(new_amount)

# Starting Cash
var money: int = 500

var current_round: int = 0

func add_money(amount: int):
    money += amount
    emit_signal("money_changed", money)
    print("Money Added. Total: ", money)

func remove_money(amount: int) -> bool:
    if money >= amount:
        money -= amount
        emit_signal("money_changed", money)
        return true # Purchase successful!
    else:
        print("Not enough cash!")
        return false # Purchase failed