extends Node3D
class_name Enemy

@export var enemy_settings:EnemySettings


signal enemy_finished

var enemy_health:int

var attackable:bool = false
var distance_traveled:float = 0

var path_3d:Path3D
var path_follow_3d:PathFollow3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_health = enemy_settings.health
	$Path3D.curve = path_route_to_curve_3d()
	$Path3D/PathFollow3D.progress = 0

func _on_spawning_state_entered() -> void:
	print("Spawning")
	attackable = false
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_traveling")


func _on_traveling_state_entered() -> void:
	print("Traveling")
	attackable = true


func _on_traveling_state_processing(delta: float) -> void:
	distance_traveled += (delta * enemy_settings.speed)
	var distance_traveled_on_screen:float = clamp(distance_traveled, 0, PathGenInstance.get_path_route().size()-1)
	$Path3D/PathFollow3D.progress = distance_traveled_on_screen
	
	if distance_traveled > PathGenInstance.get_path_route().size()-1:
		$EnemyStateChart.send_event("to_damaging")


func _on_despawning_state_entered() -> void:
	enemy_finished.emit()
	$AnimationPlayer.play("despawn")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_remove_enemy")

func _on_remove_enemy_state_entered() -> void:
	queue_free()

func _on_damaging_state_entered() -> void:
	attackable = false
	print("doing some damage!")
	$EnemyStateChart.send_event("to_despawning")

func _on_dying_state_entered() -> void:
	enemy_finished.emit()
	print("Playing sound")
	$ExplosionAudio.play()
	$Path3D/PathFollow3D/enemy_ufo_a2.visible = false
	await $ExplosionAudio.finished
	$EnemyStateChart.send_event("to_remove_enemy")

func path_route_to_curve_3d() -> Curve3D:
	var c3d:Curve3D = Curve3D.new()
	
	for element in PathGenInstance.get_path_route():
		c3d.add_point(Vector3(element.x, 0.25, element.y))

	return c3d
	
	

func _on_area_3d_area_entered(area):
	print("enemy_health:", enemy_health)
	if area is Projectile:
		enemy_health -= area.damage

	if enemy_health <= 0:
		$EnemyStateChart.send_event("to_dying")
