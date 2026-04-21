extends Panel
class_name TowerQuantityPanel

@onready var quantity_label: Label = %QuantityLabel

func update_quantity(amount: int, max_amount: int) -> void:
	quantity_label.text = "%d / %d" % [amount, max_amount]
