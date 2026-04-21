extends Resource
class_name LevelInfo

@export_range(1, 100, 1, "or_greater") var number: int = 1
@export var title: String
@export_file("level_*.tscn") var scene: String
@export var stats: LevelStats
@export var waves: Array[EnemyWave]
