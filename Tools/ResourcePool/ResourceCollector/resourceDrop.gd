class_name ResourceDrop extends Area2D

const ACCEPTABLE_BOB_DISTANCE = 1

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var start_offset = sprite_2d.offset

@export var resource_identifier: String = "Money"
@export var amount: int = 1


func on_body_entered(body: Node2D):
	var body_children = body.get_children()
	if body_children.is_empty():
		return
	var resource_collectors = []
	for child in body_children:
		if child is ResourceCollector:
			resource_collectors.append(child)
	
	if resource_collectors.is_empty():
		return

	for resource_collector in resource_collectors:
		if resource_collector.collect_resource_identifier == resource_identifier:
			resource_collector.collect_resource(self)
