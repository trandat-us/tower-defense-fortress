extends EntityInfo
class_name TowerInfo

const REFUND_PERCENT = 0.7 # refund 70% of total cost if tower get demolished

@export_group("Attributes")
@export_range(1, 500, 1, "or_greater", "hide_control", "suffix:hp") var max_health: Array[int]
@export_range(1, 500, 1, "or_greater", "hide_control", "suffix:atk") var attack_damage: Array[int]
@export_range(1, 10, 0.01, "or_greater", "hide_control", "suffix:m") var attack_range: Array[float]
@export_range(0.01, 2, 0.01, "or_greater", "hide_control", "suffix:s") var reload_times: Array[float]
var health: int:
	set(value):
		health = clampi(value, 0, max_health[level - 1])

@export_group("Progress")
@export_range(1, 10, 1, "or_greater") var max_level: int = 5
var level: int = 1:
	set(value):
		level = clampi(value, 1, max_level)

@export_group("Economy")
@export_range(1, 200, 1, "or_greater", "suffix:golds") var base_cost: int = 100
@export_range(1, 500, 1, "or_greater", "hide_control", "suffix:golds") var upgrade_costs: Array[int]

func get_next_level_cost() -> int:
	return upgrade_costs[level - 1]

func get_total_cost() -> int:
	var cost := base_cost
	for i in range(level - 1):
		cost += upgrade_costs[i]
	return cost

func get_refund_amount() -> int:
	return floori(get_total_cost() * REFUND_PERCENT)

func get_attribute(attribute: StringName) -> Variant:
	var att = get(attribute)
	if not att:
		return null
	
	if att is Array:
		return att[level - 1]
	
	return att
