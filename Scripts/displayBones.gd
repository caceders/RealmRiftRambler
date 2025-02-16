extends Label

@export var resource: ResourceCollector

func _process(delta):
	text = var_to_str(resource.amount as int)
