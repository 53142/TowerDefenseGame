extends Label
class_name MoneyLabel

@onready var main_class = $"../.."

func _ready() -> void:
	text = "Money: $" + str(main_class.money) # Display starting amount of money

func add_money(money: int) -> void:
	main_class.money += money
	text = "Money: $" + str(main_class.money)

func subtract_money(money: int) -> void:
	main_class.money -= money
	text = "Money: $" + str(main_class.money)
