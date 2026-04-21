class_name SceneTimer
extends RefCounted

signal timeout

var duration: float
var elapsed: float = 0.0
var loop: bool = false
var is_running: bool = false

func _init(p_duration: float, p_loop: bool = false, p_autostart: bool = false) -> void:
	duration = p_duration
	loop = p_loop
	if p_autostart:
		start()

func start() -> void:
	elapsed    = 0.0
	is_running = true

func stop() -> void:
	is_running = false

func pause() -> void:
	is_running = false

func resume() -> void:
	is_running = true

func tick(delta: float) -> void:
	if not is_running:
		return
	
	elapsed += delta
	if elapsed >= duration:
		if loop:
			elapsed = fmod(elapsed, duration)
		else:
			elapsed = duration
			is_running = false
		timeout.emit()

func get_progress() -> float:
	return clamp(elapsed / duration, 0.0, 1.0)

func get_remaining() -> float:
	return max(duration - elapsed, 0.0)
