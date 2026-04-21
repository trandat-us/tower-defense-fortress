extends Node3D
class_name EnemyPaths

signal wave_started
signal wave_ended

const ENEMY_PATH_COLORS = preload("uid://dqtameljplkuv")
const ENEMY_PATH_FOLLOW = preload("uid://fsvtxrmnfnf5")
const PATH_DASHED_LINE_SHADER = preload("uid://c06co11f8vacv")

@export_group("Path Visual", "path_visual_")
@export_range(0.001, 0.1, 0.001, "or_greater", "suffix:m") var path_visual_width: float = 0.03
@export_range(0.01, 10, 0.01, "or_greater", "suffix:s") var path_visual_reveal_duration: float = 3
@export_range(0.001, 1, 0.001, "or_greater", "suffix:s") var path_visual_hide_duration: float = 0.3

enum State {
	NONE,
	PREPARATION,
	SPAWNING,
	FINISHED_SPAWNING
}

var paths: Array[Path3D]
var enemy_wave: EnemyWave
var time_scale: float = 1.0
var state: State = State.NONE

var total_enemy_amount: int = 0
var spawned_enemy_amount: int = 0
var enemy_path_follows: Array[EnemyPathFollow]
var scene_timers: Array[SceneTimer]
var path_material: Dictionary[Path3D, ShaderMaterial] = {}

var _shader_time: float = 0

func _ready() -> void:
	for child in get_children():
		if child is Path3D:
			paths.append(child)
	
	LevelEvents.speed_boost_toggled.connect(_on_speed_boost_toggled)

func _process(delta: float) -> void:
	_shader_time += delta
	
	for timer in scene_timers:
		timer.tick(delta * time_scale)
	
	if not path_material.is_empty():
		for mat in path_material.values():
			mat.set_shader_parameter("shader_time", _shader_time)
	
	match state:
		State.SPAWNING:
			if spawned_enemy_amount == total_enemy_amount:
				state = State.FINISHED_SPAWNING
		State.FINISHED_SPAWNING:
			if enemy_path_follows.is_empty():
				state = State.NONE
				wave_ended.emit()

func prepare_wave(wave: EnemyWave) -> void:
	path_material.clear()
	
	if not wave:
		push_warning("No wave to prepare")
		return
	
	state = State.PREPARATION
	
	enemy_wave = wave
	total_enemy_amount = 0
	spawned_enemy_amount = 0
	enemy_path_follows.clear()
	
	for lane in enemy_wave.lanes:
		for burst in lane.bursts:
			total_enemy_amount += burst.amount
	
	_visualize_path_lines()

func start_wave() -> void:
	if not state == State.PREPARATION:
		return
	
	wave_started.emit()
	state = State.SPAWNING
	for lane in enemy_wave.lanes:
		_handle_enemy_lane(lane)

func hide_path_lines() -> void:
	var tween = create_tween().set_parallel()
	for path in path_material.values():
		tween.tween_method(
			func(value):
				path.set_shader_parameter("color_correction", value), 
			1.0, 0.0, path_visual_hide_duration
		)

func _visualize_path_lines() -> void:
	for i in range(enemy_wave.lanes.size()):
		var lane = enemy_wave.lanes[i]
		if lane.path_index > paths.size():
			return
		
		var path = paths[lane.path_index]
		if path_material.has(path):
			continue
		
		var mat = _draw_path_line(path, i)
		path_material[path] = mat
	
	var tween = create_tween().set_parallel()
	for path in path_material.values():
		tween.tween_method(
			func(value):
				path.set_shader_parameter("reveal_progress", value),
			0.0, 1.0, path_visual_reveal_duration
		)

func _draw_path_line(path: Path3D, idx: int = 0) -> ShaderMaterial:
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var material = ShaderMaterial.new()
	
	var path_total_length := path.curve.get_baked_length()
	var path_current_length := 0.0
	var from_points: Dictionary[Vector3, Dictionary] = {}
	var points_count := path.curve.point_count - 1
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(points_count):
		var start_point := path.curve.get_point_position(i)
		var end_point := path.curve.get_point_position(i + 1)
		var crossbar_points := _get_crossbar_points(start_point, end_point)
		
		if from_points.has(start_point):
			var sub_dict = from_points[start_point]
			crossbar_points["from_1"] = sub_dict["from_1"]
			crossbar_points["from_2"] = sub_dict["from_2"]
		
		if i + 2 < points_count:
			var next_end_point := path.curve.get_point_position(i + 2)
			var next_crossbar_points :=  _get_crossbar_points(end_point, next_end_point)
			
			var to_1 = _get_intersection_point(
				crossbar_points["from_1"], 
				crossbar_points["to_1"], 
				next_crossbar_points["from_1"], 
				next_crossbar_points["to_1"]
			)
			var to_2 = _get_intersection_point(
				crossbar_points["from_2"], 
				crossbar_points["to_2"], 
				next_crossbar_points["from_2"], 
				next_crossbar_points["to_2"]
			)
			crossbar_points["to_1"] = to_1
			crossbar_points["to_2"] = to_2
			
			var sub_dict: Dictionary = {}
			sub_dict["from_1"] = to_1
			sub_dict["from_2"] = to_2
			from_points[end_point] = sub_dict
		
		var start_uv := path_current_length / path_total_length
		path_current_length += end_point.distance_to(start_point)
		var end_uv := path_current_length / path_total_length
		
		immediate_mesh.surface_set_uv(Vector2(0, start_uv))
		immediate_mesh.surface_add_vertex(crossbar_points["from_1"])
		immediate_mesh.surface_set_uv(Vector2(1, start_uv))
		immediate_mesh.surface_add_vertex(crossbar_points["from_2"])
		immediate_mesh.surface_set_uv(Vector2(0, end_uv))
		immediate_mesh.surface_add_vertex(crossbar_points["to_1"])
		
		immediate_mesh.surface_set_uv(Vector2(0, end_uv))
		immediate_mesh.surface_add_vertex(crossbar_points["to_1"])
		immediate_mesh.surface_set_uv(Vector2(1, start_uv))
		immediate_mesh.surface_add_vertex(crossbar_points["from_2"])
		immediate_mesh.surface_set_uv(Vector2(1, end_uv))
		immediate_mesh.surface_add_vertex(crossbar_points["to_2"])
	
	immediate_mesh.surface_end()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.material_override = material
	
	material.shader = PATH_DASHED_LINE_SHADER
	material.set_shader_parameter("color", ENEMY_PATH_COLORS.colors[idx])
	
	path.add_child(mesh_instance)
	mesh_instance.position.y += idx * 0.01
	return material

func _get_intersection_point(from_1: Vector3, to_1: Vector3, from_2: Vector3, to_2: Vector3) -> Vector3:
	var den := (from_1.x - to_1.x) * (from_2.z - to_2.z) - (from_1.z - to_1.z) * (from_2.x - to_2.x)
	var t := ((from_1.x - from_2.x) * (from_2.z - to_2.z) - (from_1.z - from_2.z) * (from_2.x - to_2.x)) / den
	return from_1 + t * (to_1 - from_1)

func _get_crossbar_points(pos_1: Vector3, pos_2: Vector3) -> Dictionary:
	var pos_dir := pos_1.direction_to(pos_2)
	var cross_dir := pos_dir.cross(Vector3.UP)
	var offset := path_visual_width / 2
	
	var result: Dictionary = {}
	result["from_1"] = pos_1 + offset * cross_dir
	result["to_1"] = pos_2 + offset * cross_dir
	result["from_2"] = pos_1 - offset * cross_dir
	result["to_2"] = pos_2 - offset * cross_dir
	return result

func _handle_enemy_lane(lane: EnemyLane) -> void:
	var path = paths[lane.path_index]
	if not path:
		push_warning("No path with index " + str(lane.path_index))
		return
	
	for burst in lane.bursts:
		_handle_enemy_burst(path, burst)

func _handle_enemy_burst(path: Path3D, burst: EnemyBurst) -> void:
	var delay_timer = SceneTimer.new(burst.delay, false, true)
	scene_timers.append(delay_timer)
	await delay_timer.timeout
	scene_timers.erase(delay_timer)
	
	for i in range(burst.amount):
		var path_follow = ENEMY_PATH_FOLLOW.instantiate() as EnemyPathFollow
		path.add_child(path_follow)
		if path_follow.attach_enemy(burst.enemy):
			path_follow.time_scale = time_scale
			enemy_path_follows.append(path_follow)
			spawned_enemy_amount += 1
			path_follow.tree_exited.connect(func(): enemy_path_follows.erase(path_follow))
		else:
			total_enemy_amount -= 1
			path_follow.queue_free()
			continue
		
		if i < burst.amount - 1:
			var interval_timer = SceneTimer.new(burst.interval, false, true)
			scene_timers.append(interval_timer)
			interval_timer.start()
			await interval_timer.timeout
			scene_timers.erase(interval_timer)

func _on_speed_boost_toggled(speed_scale: float) -> void:
	time_scale = speed_scale
	for pl in enemy_path_follows:
		pl.time_scale = time_scale
