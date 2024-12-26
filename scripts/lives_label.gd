extends Label
class_name LivesLabel

var current_lives: int = 10

func _ready() -> void:
	text = "Lives: " + str(current_lives) # Display starting number of lives

func decrement_lives() -> void:
	current_lives-=1
	text = "Lives: " + str(current_lives)
	if current_lives < 1:
		# Game over
		pass
