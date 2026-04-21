extends Panel
class_name GoldCollectedPanel

@onready var gold_label: Label = %GoldLabel

func update_golds(amount: int) -> void:
	gold_label.text = str(amount)
