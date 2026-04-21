extends Control
class_name MainMenu

@onready var main_controls: Control = $MainControls
@onready var select_mode_controls: Control = $SelectModeControls
@onready var level_select_controls: Control = $LevelSelectControls
@onready var bgm: AudioStreamPlayer = $BGM

func _ready() -> void:
	main_controls.modulate.a = 0
	
	select_mode_controls.position.x += 32
	select_mode_controls.visible = false
	select_mode_controls.modulate.a = 0
	
	level_select_controls.position.x += 32
	level_select_controls.visible = false
	level_select_controls.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property(main_controls, "modulate:a", 1, 0.5).set_delay(0.2)
	tween.tween_callback(bgm.play)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if select_mode_controls.visible:
			_on_back_main_button_pressed()
		elif level_select_controls.visible:
			_on_back_mode_button_pressed()

func _on_play_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(main_controls, "modulate:a", 0, 0.3)
	tween.tween_callback(main_controls.set.bind("visible", false))
	
	tween.tween_callback(select_mode_controls.set.bind("visible", true)).set_delay(0.2)
	tween.tween_property(select_mode_controls, "position:x", position.x - 32, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).as_relative()
	tween.parallel().tween_property(select_mode_controls, "modulate:a", 1, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_back_main_button_pressed() -> void:
	var tween = create_tween()
	
	tween.tween_property(select_mode_controls, "position:x", position.x + 32, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).as_relative()
	tween.parallel().tween_property(select_mode_controls, "modulate:a", 0, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_callback(select_mode_controls.set.bind("visible", false))
	
	tween.tween_callback(main_controls.set.bind("visible", true)).set_delay(0.2)
	tween.tween_property(main_controls, "modulate:a", 1, 0.3)

func _on_back_mode_button_pressed() -> void:
	var tween = create_tween()
	
	tween.tween_property(level_select_controls, "position:x", position.x + 32, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).as_relative()
	tween.parallel().tween_property(level_select_controls, "modulate:a", 0, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_callback(level_select_controls.set.bind("visible", false))
	
	tween.tween_callback(select_mode_controls.set.bind("visible", true)).set_delay(0.2)
	tween.tween_property(select_mode_controls, "position:x", position.x - 32, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).as_relative()
	tween.parallel().tween_property(select_mode_controls, "modulate:a", 1, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

func _on_classic_button_pressed() -> void:
	var tween = create_tween()
	
	tween.tween_property(select_mode_controls, "position:x", position.x + 32, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).as_relative()
	tween.parallel().tween_property(select_mode_controls, "modulate:a", 0, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_callback(select_mode_controls.set.bind("visible", false))
	
	tween.tween_callback(level_select_controls.set.bind("visible", true)).set_delay(0.2)
	tween.tween_property(level_select_controls, "position:x", position.x - 32, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).as_relative()
	tween.parallel().tween_property(level_select_controls, "modulate:a", 1, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

func _on_endless_button_pressed() -> void:
	pass # Replace with function body.
