# HAPPENS WHEN ATTACKS SOMETHING OUTSIDE OF RANGE

extends Node3D

var enemies_in_range:Array[Node3D]
var current_enemy:Node3D = null
var current_enemy_class:Enemy = null
var current_enemy_targetted:bool = false
var acquire_slerp_progress:float = 0

var last_fire_time:int
@export var fire_rate_ms:int = 500
@export var projectile_type:PackedScene

func _on_patrol_zone_area_entered(area):
	#print(area, " entered")
	if current_enemy == null:
		current_enemy = area
	enemies_in_range.append(area)
	print("enemies in range:", enemies_in_range)

func _on_patrol_zone_area_exited(area):
	enemies_in_range.erase(area)
	if current_enemy == area:
		current_enemy = null
		$StateChart.send_event("to_patrolling_state")
	print("enemies in range:", enemies_in_range)

func set_patrolling(patrolling:bool):
	$PatrolZone.monitoring = patrolling
	
func rotate_towards_target(rtarget, delta):
	#if rtarget == null:
		#return
	var target_vector = $Cannon.global_position.direction_to(Vector3(rtarget.global_position.x, global_position.y, rtarget.global_position.z))
	var target_basis:Basis = Basis.looking_at(target_vector)
	$Cannon.basis = $Cannon.basis.slerp(target_basis, acquire_slerp_progress)
	acquire_slerp_progress += delta
	if acquire_slerp_progress >= 1:
		$StateChart.send_event("to_attacking_state")

func _find_enemy_parent(n:Node):
	if n is Enemy:
		return n
	elif n.get_parent() != null:
		return _find_enemy_parent(n.get_parent())
	else:
		return null

func _on_patrolling_state_state_processing(_delta):
	if enemies_in_range.size() > 0:
		current_enemy = enemies_in_range[0]
		current_enemy_class = _find_enemy_parent(current_enemy)
		current_enemy_class.enemy_finished.connect(_remove_current_enemy)
		$StateChart.send_event("to_acquiring_state")
	else:
		current_enemy = null

func _remove_current_enemy():
	print("Enemy finished")
	enemies_in_range.erase(current_enemy)
	current_enemy = null
	current_enemy_class = null
	$StateChart.send_event("to_patrolling_state")

func _on_acquiring_state_state_entered():
	current_enemy_targetted = false
	acquire_slerp_progress = 0

func _on_acquiring_state_state_physics_processing(delta):
	#print("Current enemy state", current_enemy != null)
	#print("Current enemy in range", enemies_in_range.has(current_enemy)) 
	#rotate_towards_target(current_enemy, delta)
	# If currently targeting an enemy
	if current_enemy == null or not enemies_in_range.has(current_enemy):
		$StateChart.send_event("to_patrolling_state")
		return
	rotate_towards_target(current_enemy, delta)

func _on_attacking_state_state_physics_processing(_delta):
	# If currently targeting an enemy
	if current_enemy != null and enemies_in_range.has(current_enemy):
		# Disregard invalid enemies
		if not current_enemy_class or not current_enemy_class.attackable:
			enemies_in_range.erase(current_enemy)
			current_enemy = null
			current_enemy_class = null
			$StateChart.send_event("to_patrolling_state")
			return

		$Cannon.look_at(current_enemy.global_position)
		# If cooldown over
		if Time.get_ticks_msec() > (last_fire_time+fire_rate_ms):
			fire()
	else:
		$StateChart.send_event("to_patrolling_state")

func fire():
	var projectile:Projectile = projectile_type.instantiate()
	projectile.starting_position = $Cannon/projectile_spawn.global_position
	projectile.target = current_enemy # should be improved later so projectiles aren't tracking bc kinda weird
	add_child(projectile)
	last_fire_time = Time.get_ticks_msec()

func _on_attacking_state_state_entered():
	#last_fire_time = 0
	last_fire_time = -fire_rate_ms
