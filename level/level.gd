extends Node3D
class_name Level

const DROPPED_GOLDS_SPRITE = preload("uid://hjk5fl8gkofv")

@onready var map: Node3D = $Map
@onready var tiles: GridMap = %Tiles
@onready var towers: Node3D = %Towers
@onready var hud: HUD = $HUD
@onready var camera_pivot: CameraPivot = $CameraPivot
@onready var enemy_paths: EnemyPaths = $EnemyPaths
@onready var bgm: AudioStreamPlayer = $BGM

@export var info: LevelInfo

var _focusing_tower: Tower
var _dragging_tower: Tower
var _occupied_tiles: Dictionary[Vector3, Tower]
var _can_drop_tower: bool = false
var _level_finished: bool = false
var _can_pause: bool = false

var stats: LevelStats
var waves: Array[EnemyWave]
var current_wave: EnemyWave
var time_scale: float = 1

func _ready() -> void:
	waves = info.waves.duplicate(true)
	stats = info.stats.duplicate(true)
	stats.max_wave = waves.size()
	current_wave = waves.pop_front()
	
	LevelEvents.tower_card_drag_started.connect(_on_tower_card_drag_started)
	LevelEvents.tower_card_dropped.connect(_on_tower_card_dropped)
	
	LevelEvents.an_enemy_died.connect(_on_an_enemy_died)
	LevelEvents.an_enemy_reached_end.connect(_on_an_enemy_reached_end)
	
	LevelEvents.speed_boost_toggled.connect(_on_speed_boost_toggled)
	
	if info and stats:
		hud.init_info(info, stats)

func _process(delta: float) -> void:
	if _dragging_tower:
		var tile_query = _create_mouse_ray_query(tiles.collision_layer)
		if tile_query:
			_snap_dragging_tower(tile_query)
			_can_drop_tower = _check_tower_droppable()
			_dragging_tower.display_placeable_plane(_can_drop_tower)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_click"):
		var tower_query = _create_mouse_ray_query(2)
		if tower_query:
			var _tower = _check_clicked_tower(tower_query)
			if not _tower:
				return
			
			if _focusing_tower:
				if _focusing_tower == _tower:
					return
				else:
					unfocus_tower()
			
			_focusing_tower = _tower
			_focusing_tower.focus()
			camera_pivot.move_to_position(_focusing_tower.global_position)
			hud.display_tower_detail(_focusing_tower)
		else:
			unfocus_tower()
	elif event.is_action_pressed("ui_cancel"):
		if _dragging_tower:
			_can_drop_tower = false
			_dragging_tower.queue_free()
			_dragging_tower = null
			return
		
		if _can_pause:
			if get_tree().paused:
				LevelEvents.level_unpaused.emit()
			else:
				LevelEvents.level_paused.emit()

func upgrade_tower(tower: Tower) -> bool:
	if not tower:
		return false
	
	if not _occupied_tiles.has(tower.global_position):
		return false
	
	var upgrade_cost = tower.info.get_next_level_cost()
	if stats.golds < upgrade_cost:
		return false
	
	stats.golds -= upgrade_cost
	tower.level_up()
	return true

func demolish_tower(tower: Tower) -> bool:
	if not _occupied_tiles.has(tower.global_position):
		return false 
	
	if not tower == _focusing_tower:
		return false
	
	stats.golds += tower.info.get_refund_amount()
	stats.tower_quantity -= 1
	
	unfocus_tower() 
	tower.queue_free()
	_occupied_tiles.erase(tower.global_position)
	return true

func unfocus_tower() -> void:
	if _focusing_tower:
		hud.hide_tower_detail()
		_focusing_tower.un_focus()
		_focusing_tower = null

func _create_mouse_ray_query(mask: int = 1, collide_with_areas: bool = false) -> Dictionary:
	var mouse_pos := get_viewport().get_mouse_position()
	var camera := get_viewport().get_camera_3d()
	var origin := camera.project_ray_origin(mouse_pos)
	var normal := origin + camera.project_ray_normal(mouse_pos) * 100.0
	
	var query := PhysicsRayQueryParameters3D.create(origin, normal)
	query.collision_mask = mask
	query.collide_with_areas = collide_with_areas
	
	var world := get_world_3d().direct_space_state
	
	return world.intersect_ray(query)

# Snap the dragging tower to tiles
func _snap_dragging_tower(tile_query: Dictionary) -> void:
	var pos = tiles.map_to_local(tile_query.position)
	# For some reason, if query's x or z position < 0, the result is shifted right by 1 m
	if tile_query.position.x < 0:
		pos.x -= tiles.cell_size.x
	if tile_query.position.z < 0:
		pos.z -= tiles.cell_size.z
	_dragging_tower.global_position = pos

func _check_tower_droppable() -> bool:
	# Check if reach max towers to place
	if _occupied_tiles.size() >= stats.max_towers:
		return false
	
	# Check if current gold lower than base cost
	if stats.golds < _dragging_tower.info.base_cost:
		return false
	
	# Check if current snapped position is occupied
	if _occupied_tiles.has(_dragging_tower.global_position):
		return false
	
	# Check if below tile at snapped position is not "tile"
	var beneath_tile_pos = _dragging_tower.global_position
	beneath_tile_pos.y -= tiles.cell_size.y
	
	var tile_local_pos = tiles.local_to_map(beneath_tile_pos)
	var tile_idx = tiles.get_cell_item(tile_local_pos)
	if not tiles.mesh_library.get_item_list().has(tile_idx):
		return false
	
	var tile_name = tiles.mesh_library.get_item_name(tile_idx)
	if tile_name != "tile":
		return false
	return true

func _check_clicked_tower(tower_query: Dictionary) -> Tower:
	var pos = tiles.map_to_local(tower_query.position)
	# For some reason, if query's x or z position < 0, the result is shifted right by 1 m
	if tower_query.position.x < 0:
		pos.x -= tiles.cell_size.x
	if tower_query.position.z < 0:
		pos.z -= tiles.cell_size.z
	if _occupied_tiles.has(pos):
		return _occupied_tiles[pos]
	return null

func _on_tower_card_drag_started(tower_scene: PackedScene) -> void:
	var instance = tower_scene.instantiate()
	if not instance is Tower:
		return
	
	unfocus_tower()
	_dragging_tower = tower_scene.instantiate()
	towers.add_child(_dragging_tower)

func _on_tower_card_dropped() -> void:
	if not _dragging_tower:
		return
	
	if _can_drop_tower:
		stats.golds -= _dragging_tower.info.base_cost
		stats.tower_quantity += 1
		
		_occupied_tiles[_dragging_tower.global_position] = _dragging_tower
		_dragging_tower.on_place(time_scale)
		_can_drop_tower = false
	else:
		_dragging_tower.queue_free()
	_dragging_tower = null

func _on_an_enemy_reached_end(enemy: Enemy) -> void:
	stats.health -= 1
	if stats.health == 0:
		_finish_level(false)

func _on_an_enemy_died(enemy: Enemy) -> void:
	stats.golds += enemy.info.dropped_golds
	var box = DROPPED_GOLDS_SPRITE.instantiate() as Node3D
	box.golds = enemy.info.dropped_golds
	box.start_position = enemy.global_position
	map.add_child(box)

func _on_speed_boost_toggled(speed_scale: float) -> void:
	time_scale = speed_scale
	for tower in _occupied_tiles.values():
		tower.time_scale = time_scale
	
	for tower_projectile in get_tree().get_nodes_in_group("tower_projectile"):
		tower_projectile.time_scale = time_scale

func _on_enemy_paths_wave_ended() -> void:
	if _level_finished:
		return
	
	current_wave = waves.pop_front()
	if current_wave:
		await get_tree().create_timer(2.0).timeout
		stats.wave_number += 1
		hud.enter_prepare_phase()
		enemy_paths.prepare_wave(current_wave)
	else:
		_finish_level(not stats.health == 0)

func _on_hud_ingame_controls_showed_up() -> void:
	camera_pivot.unlock()
	hud.enter_prepare_phase()
	enemy_paths.prepare_wave(current_wave)
	_can_pause = true

func _on_hud_tower_detail_panel_closed() -> void:
	unfocus_tower()

func _on_hud_prepare_phase_ended() -> void:
	enemy_paths.hide_path_lines()
	await get_tree().create_timer(2.0).timeout
	enemy_paths.start_wave()

func _finish_level(success: bool) -> void:
	if _level_finished:
		return
	
	_level_finished = true
	
	var gained_trophies := stats.get_trophies()
	if success:
		# Update current level progress
		UserProgressManager.update_level_passed(info.number, gained_trophies)
		UserProgressManager.unlock_level(info.number + 1)
	
	# UI things
	camera_pivot.lock()
	await get_tree().create_timer(2.0).timeout
	hud.show_result(success, gained_trophies)
	bgm.stop()
