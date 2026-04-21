extends Control
class_name CountdownPanel

signal timeout

@onready var countdown_label: Label = %CountdownLabel
@onready var countdown_timer: Timer = $CountdownTimer

func _ready() -> void:
	reset()

func _process(delta: float) -> void:
	if countdown_timer.is_stopped():
		return
	
	set_time_label(countdown_timer.time_left)

func reset() -> void:
	set_time_label(countdown_timer.wait_time)

func set_time_label(time: float) -> void:
	var minutes = floor(time / 60)
	var seconds = int(time) % 60
	
	countdown_label.text = "%02d : %02d" % [minutes, seconds]

func start(second: int = 90) -> void:
	countdown_timer.wait_time = second
	countdown_timer.start()

func stop() -> void:
	countdown_timer.stop()

func _on_countdown_timer_timeout() -> void:
	timeout.emit()
