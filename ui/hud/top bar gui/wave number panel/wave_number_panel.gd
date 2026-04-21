extends Panel
class_name WaveNumberPanel

@onready var wave_label: Label = $WaveLabel

func update_wave_number(number: int, max_number: int) -> void:
	wave_label.text = "Wave %d / %d" % [number, max_number]
