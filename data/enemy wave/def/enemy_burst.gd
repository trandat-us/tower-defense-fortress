extends Resource
class_name EnemyBurst

@export var enemy: PackedScene
@export_range(1, 10, 1, "or_greater") var amount: int = 5
@export_range(0.01, 10, 0.01, "or_greater", "hide_control", "suffix:s") var interval: float = 2.0 
@export_range(0, 10, 0.01, "or_greater", "hide_control", "suffix:s") var delay: float = 0.0
