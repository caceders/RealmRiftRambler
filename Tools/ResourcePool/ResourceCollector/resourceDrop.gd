class_name ResourceDrop extends Area2D

const ACCEPTABLE_BOB_DISTANCE = 1

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var start_offset = sprite_2d.offset

@export var resource_identifier: String = "Money"
@export var amount: int = 1
@export var collection_animation: PackedScene
@export var bob = true
@export var bob_range: float = 2
@export var bob_speed: float = .5
var bob_up = true

func _ready():
	body_entered.connect(on_body_entered)
	if bob:
		sprite_2d.offset.y = start_offset.y + randf_range(-bob_range, bob_range)

func _process(delta):
	if bob:
		if bob_up:
			sprite_2d.offset.y = lerp(sprite_2d.offset.y, start_offset.y + bob_range, bob_speed/10)
			if abs((sprite_2d.offset.y - start_offset.y) - bob_range) < 1:
				bob_up = false
		else:
			sprite_2d.offset.y = lerp(sprite_2d.offset.y, start_offset.y - bob_range, bob_speed/10)
			if abs((sprite_2d.offset.y - start_offset.y) + bob_range) < 1:
				bob_up = true


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
			queue_free()
