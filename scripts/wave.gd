extends Resource
class_name Wave  # Makes it usable as a type in the editor

@export var enemies: Array[PackedScene] = []  # List of enemy scenes
@export var spawn_count: int = 5              # Number of enemies
@export var spawn_interval: float = 1.5       # Time between spawns
@export var start_delay: float = 0.0          # Delay before wave starts
