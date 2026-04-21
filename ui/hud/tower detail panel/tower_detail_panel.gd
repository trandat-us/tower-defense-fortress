extends Control
class_name TowerDetailPanel

signal closed_button_pressed

@onready var preview_texture: TextureRect = %PreviewTexture
@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel

@onready var health_label_value: Label = %HealthLabelValue
@onready var damage_value_label: Label = %DamageValueLabel
@onready var range_value_label: Label = %RangeValueLabel
@onready var reload_value_label: Label = %ReloadValueLabel

@onready var upgrade_button: Button = %UpgradeButton
@onready var upgrade_cost_label: Label = %UpgradeCostLabel
@onready var demolish_refund_label: Label = %DemolishRefundLabel

var cur_tower: Tower

func update_detail(tower: Tower) -> void:
	cur_tower = tower
	var info = cur_tower.info
	
	preview_texture.texture = info.icon
	title_label.text = info.name.capitalize()
	subtitle_label.text = "%s  •  Lv. %d" % [info.title.capitalize(), info.level]
	
	health_label_value.text = "%d / %d HP" % [info.health, info.get_attribute(AttributeNames.MAX_HEALTH)]
	damage_value_label.text = "%d ATK" % [info.get_attribute(AttributeNames.ATTACK_DAMAGE)]
	range_value_label.text = str(info.get_attribute(AttributeNames.ATTACK_RANGE)) + " m"
	reload_value_label.text = str(info.get_attribute(AttributeNames.RELOAD_TIMES)) + " s"
	
	if info.level == info.max_level:
		upgrade_button.visible = false
	else:
		upgrade_button.visible = true
		upgrade_cost_label.text = "- " + str(info.get_next_level_cost())
	demolish_refund_label.text = "+ " + str(info.get_refund_amount())

func _on_close_button_pressed() -> void:
	cur_tower = null
	closed_button_pressed.emit()

func _on_upgrade_button_pressed() -> void:
	var level = get_tree().get_first_node_in_group("level") as Level
	if level and level.upgrade_tower(cur_tower):
		update_detail(cur_tower)

func _on_demolish_button_pressed() -> void:
	var level = get_tree().get_first_node_in_group("level") as Level
	if level and cur_tower:
		level.demolish_tower(cur_tower)
