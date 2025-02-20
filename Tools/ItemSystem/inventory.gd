class_name Inventory extends Node

@export var _items: Dictionary = {}

func add_item(item: Item, amount = 1):
	if _items.has(item):
		_items[item] += amount
	else:
		_items[item] = amount

func remove_item(item: Item, amount = 1):
	if _items[item] == amount:
		_items.erase(item)
	elif _items[item] < amount:
		push_error("Tried to remove more of an item than inventory had")
	else:
		_items[item] -= amount

func get_number_of_item(item):
	if _items.has(item):
		return _items[item]
	else:
		return 0

func get_items():
	return _items.duplicate(true) 