class_name ResourceCollector extends ResourcePool

@export var collect_resource_identifier: String = "Money"

func collect_resource(resource_drop: ResourceDrop):
	amount += resource_drop.amount