extends Node

signal tower_card_drag_started(tower_scene: PackedScene)
signal tower_card_dropped

signal an_enemy_died(enemy: Enemy)
signal an_enemy_reached_end(enemy: Enemy)

signal speed_boost_toggled(speed_scale: float)

signal level_unpaused
signal level_paused
