extends Node3D
class_name main_class

@export var tile_start:PackedScene
@export var tile_end:PackedScene
@export var tile_straight:PackedScene
@export var tile_corner:PackedScene
@export var tile_crossroads:PackedScene
#@export var tile_enemy:PackedScene
@export var tile_empty:Array[PackedScene]

@export var waves: Array[Wave] = []  # List of Wave resources
@export var enemy_spawn_position: Vector3 = Vector3(0, 0, 0)  # Default spawn position
@export var enemy_target_position: Vector3 = Vector3(10, 0, 10)  # Path target for enemies
@export var lives: int = 10

var current_wave_index: int = 0  # Tracks the current wave


## Assumes the path generator has finished, and adds the remaining tiles to fill in the grid.
func _ready():
	_complete_grid()
	#start_waves()

# begin waves

# Start the wave spawning process
# Called when StartWavesButton is pressed
func start_waves():
	# prob should disable startWavesButton here
	
	if waves.is_empty():
		print("No waves defined!")
		return
	_start_next_wave()

# Start spawning the current wave
func _start_next_wave():
	if current_wave_index >= waves.size():
		print("All waves complete!")
		return

	var wave = waves[current_wave_index]
	current_wave_index += 1

	print("Starting wave %d" % current_wave_index)
	call_deferred("_spawn_wave", wave)

# Spawn enemies for the given wave
func _spawn_wave(wave: Wave):
	await get_tree().create_timer(wave.start_delay).timeout  # Wait for the start delay

	for i in range(wave.spawn_count):
		for enemy_scene in wave.enemies:
			var enemy_instance: Node3D = enemy_scene.instantiate()
			add_child(enemy_instance)
			enemy_instance.global_position = enemy_spawn_position
			enemy_instance.add_to_group("enemies")

		await get_tree().create_timer(wave.spawn_interval).timeout  # Wait between spawns

	# Trigger the next wave after the current one finishes
	_start_next_wave()

# endregion wave

func _complete_grid():
	for x in range(PathGenInstance.path_config.map_length):
		for y in range(PathGenInstance.path_config.map_height):
			if not PathGenInstance.get_path_route().has(Vector2i(x,y)):
				var tile:Node3D = tile_empty.pick_random().instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
				tile.global_rotation_degrees = Vector3(0, randi_range(0,3)*90, 0)


	for i in range(PathGenInstance.get_path_route().size()):
		var tile_score:int = PathGenInstance.get_tile_score(i)
		
		var tile:Node3D = tile_empty[0].instantiate()
		var tile_rotation: Vector3 = Vector3.ZERO
		
		if tile_score == 2:
			tile = tile_end.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 8:
			tile = tile_start.instantiate()
			tile_rotation = Vector3(0,270,0)
		elif tile_score == 10:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,270,0)
		elif tile_score == 1 or tile_score == 4 or tile_score == 5:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,180,0)
		elif tile_score == 6:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 12:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,270,0)
		elif tile_score == 9:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,180,0)
		elif tile_score == 3:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 15:
			tile = tile_crossroads.instantiate()
			tile_rotation = Vector3(0,180,0)
			
		add_child(tile)
		tile.global_position = Vector3(PathGenInstance.get_path_tile(i).x, 0, PathGenInstance.get_path_tile(i).y)
		tile.global_rotation_degrees = tile_rotation

func game_over() -> void:
	$Control/UnpauseButton.show()
	get_tree().paused = true


func _on_unpause_button_pressed() -> void:
	$Control/UnpauseButton.hide()
	get_tree().paused = false
