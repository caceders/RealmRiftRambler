@tool
class_name itemDrop extends Node

const MAGNET_SPEED = 100

@export var item: Item
@export var sprite: Sprite2D
@export var pickup_animation_player: AnimationPlayer

var picked_up: bool = false

var magnet_target: Node2D = null

func _ready():
	if item != null:
		sprite.texture = item.sprite_texture
		name = item.name + "ItemDrop"

func _process(delta):
	if item != null:
		sprite.texture = item.sprite_texture
		name = item.name + "ItemDrop"
	
	if magnet_target != null:
			self.global_position += self.global_position.direction_to(magnet_target.global_position) * Vector2.ONE * (MAGNET_SPEED/(self.global_position.distance_squared_to(magnet_target.global_position) + 100))

func on_body_entered(body: Node2D):
	if body.is_in_group("Player") and not picked_up:
		if body.has_node("Inventory"):
			var inventory = body.get_node("Inventory") as Inventory
			inventory.add_item(item)
			pickup_animation_player.play("pickup")
			picked_up = true
			await pickup_animation_player.animation_finished
			self.visible = false
			self.queue_free()

func on_body_entered_magnet_area(body: Node2D):
	if body.is_in_group("Player"):
		if body.has_node("Inventory"):
			magnet_target = body

func on_body_exited_magnet_area(body: Node2D):
	if body.is_in_group("Player"):
		if body.has_node("Inventory"):
			magnet_target = null
