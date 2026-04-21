extends CanvasLayer
class_name HUD

signal ingame_controls_showed_up
signal tower_detail_panel_closed
signal prepare_phase_ended

@onready var tower_cards_h_box: HBoxContainer = %TowerCardsHBox
@onready var tower_detail_panel: TowerDetailPanel = %TowerDetailPanel
@onready var countdown_panel: CountdownPanel = %CountdownPanel
@onready var tower_detail_panel_anim_player: AnimationPlayer = $IngameControls/TowerDetailPanel/AnimPlayer
@onready var prepare_phase_anim_player: AnimationPlayer = %PreparePhaseAnimPlayer
@onready var top_bar_gui: TopBarHUD = %TopBarGUI
@onready var level_label: Label = %LevelLabel
@onready var level_result_gui: LevelResultGUI = %LevelResultGUI
@onready var ingame_controls: Control = %IngameControls
@onready var level_entry_gui: LevelEntryGUI = %LevelEntryGUI
@onready var gear_button: Button = %GearButton

@export var level: int = 1

func _ready() -> void:
	level_label.text = "Level %d" % level
	
	level_entry_gui.visible = true
	
	ingame_controls.visible = false
	ingame_controls.modulate.a = 0
	gear_button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	
	level_result_gui.visible = false

func init_info(info: LevelInfo, stats: LevelStats) -> void:
	top_bar_gui.init_level_stats(stats)
	level_entry_gui.init_level_info(info)
	level_result_gui.init_level_info(info)

func refresh_tower_detail_card(tower: Tower) -> void:
	tower_detail_panel.update_detail(tower)

func display_tower_detail(tower: Tower) -> void:
	tower_detail_panel.update_detail(tower)
	tower_detail_panel_anim_player.play("show_tower_detail_panel")

func hide_tower_detail() -> void:
	tower_detail_panel_anim_player.play("hide_tower_detail_panel")

func enter_prepare_phase() -> void:
	prepare_phase_anim_player.play("show")
	countdown_panel.reset()
	await prepare_phase_anim_player.animation_finished
	await get_tree().create_timer(0.2).timeout
	countdown_panel.start()

func show_result(success: bool, trophies: int) -> void:
	ingame_controls.visible = true
	var tween = create_tween()
	tween.tween_property(ingame_controls, "modulate:a", 0, 0.5)
	tween.tween_callback(func(): level_result_gui.display(success, trophies))

func _on_tower_detail_panel_closed_button_pressed() -> void:
	tower_detail_panel_closed.emit()

func _on_next_wave_button_pressed() -> void:
	countdown_panel.stop()
	prepare_phase_anim_player.play("hide")
	prepare_phase_ended.emit()

func _on_countdown_panel_timeout() -> void:
	prepare_phase_anim_player.play("hide")
	prepare_phase_ended.emit()

func _on_level_entry_gui_entry_ended() -> void:
	ingame_controls.visible = true
	var tween = create_tween()
	tween.tween_property(ingame_controls, "modulate:a", 1, 0.5).set_delay(0.5)
	tween.tween_callback(func():
		gear_button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
		ingame_controls_showed_up.emit()
	)

func _on_gear_button_pressed() -> void:
	LevelEvents.level_paused.emit()
