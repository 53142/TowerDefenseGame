extends Label
class_name MoneyLabel

var current_money: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_money(money: int) -> void:
	current_money += money
	text = "Money: $" + str(current_money)
