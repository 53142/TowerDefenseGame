extends Label
class_name MoneyLabel

var current_money: int = 0

func add_money(money: int) -> void:
	current_money += money
	text = "Money: $" + str(current_money)
