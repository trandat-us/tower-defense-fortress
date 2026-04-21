extends Panel
class_name TopBarHUD

@onready var health_bar: HealthBar = %HealthBar
@onready var gold_collected_panel: GoldCollectedPanel = %GoldCollectedPanel
@onready var tower_quantity_panel: TowerQuantityPanel = %TowerQuantityPanel
@onready var wave_number_panel: WaveNumberPanel = %WaveNumberPanel

func init_level_stats(stats: LevelStats) -> void:
	if stats:
		health_bar.init_bar(stats.max_health)
		gold_collected_panel.update_golds(stats.golds)
		tower_quantity_panel.update_quantity(stats.tower_quantity, stats.max_towers)
		wave_number_panel.update_wave_number(stats.wave_number, stats.max_wave)
		
		stats.health_updated.connect(
			func(value):
				health_bar.update_health(value)
		)
		stats.golds_updated.connect(
			func(value):
				gold_collected_panel.update_golds(value)
		)
		stats.tower_quantity_updated.connect(
			func(value):
				tower_quantity_panel.update_quantity(stats.tower_quantity, stats.max_towers)
		)
		stats.wave_number_updated.connect(
			func(value):
				wave_number_panel.update_wave_number(stats.wave_number, stats.max_wave)
		)
