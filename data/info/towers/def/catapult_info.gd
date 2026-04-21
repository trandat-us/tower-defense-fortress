extends TowerInfo
class_name CatapultInfo

@export_group("Unique Attributes")
@export_range(0.01, 3, 0.01, "or_greater", "suffix:m") var min_range: float = 1.5

@export_subgroup("AOE Attack", "aoe_")
@export_range(1, 3, 0.01, "or_greater", "hide_control", "suffix:m") var aoe_radius: Array[float]
@export var aoe_falloff: Curve
