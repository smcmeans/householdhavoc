extends Node

# Signal to tell the UI to update whenever money changes
signal money_changed(new_amount)

# Signal to tell the UI to update whenever lives change
signal lives_changed(new_amount)

# Starting stats
var money: int = 500
var lives: int = 100
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

func round_complete():
    @warning_ignore("integer_division")
    add_money(100 * ((current_round / 10) + 1))

func remove_life(amount: int):
    lives -= amount
    emit_signal("lives_changed", lives)
    print("Life lost! Lives remaining: ", lives)
    if lives <= 0:
        game_over()

func add_life(amount: int):
    lives += amount
    emit_signal("lives_changed", lives)
    print("Life gained! Lives now: ", lives)

func game_over():
    print("Game Over! You have run out of lives.")