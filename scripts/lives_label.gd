extends Label
class_name LivesLabel

@onready var main_class = $"../.."


func _ready() -> void:
	text = "Lives: " + str(main_class.lives) # Display starting number of lives

func decrement_lives() -> void:
	main_class.lives-=1
	text = "Lives: " + str(main_class.lives)
	if main_class.lives < 1:
		# Game over
		main_class.game_over()
