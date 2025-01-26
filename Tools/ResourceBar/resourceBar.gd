@tool

extends Control

const POSITIONAL_CORRECTION_LERP = 20
const BAR_FILL_CHANGE_PERCENTAGE_PER_SECOND = 300

enum ResourceBarType{
	SMALL_RED,
	BIG_RED,
}

@onready var sprite: Sprite2D = self.get_parent().get_node("Sprite2D")

@export var resource_bar_type : ResourceBarType = ResourceBarType.SMALL_RED
@export var resource: ResourcePool 
@export var resource_bar_offset: Vector2 = Vector2(0, -5)  # Offset above the sprite in pixels

func _process(delta):
	var _bars : Array[Node] = get_children()
	for bar in _bars:
		match resource_bar_type:
			ResourceBarType.SMALL_RED:
				if bar.name == "SmallRed" : bar.visible = true
				else: bar.visible = false
			ResourceBarType.BIG_RED:
				if bar.name == "BigRed" : bar.visible = true
				else: bar.visible = false

	if sprite != null and resource != null:
		for bar in _bars:
			bar = bar as TextureProgressBar
			# Get the sprite's bounding box
			var sprite_rect = sprite.get_rect()
			# Calculate the new position
			var new_position = Vector2(0, sprite.offset.y + (-sprite_rect.size.y / 2)) + resource_bar_offset
			self.position = self.position.lerp(new_position, 1 - exp(delta * -POSITIONAL_CORRECTION_LERP))
			bar.max_value = resource.max_amount

			if not Engine.is_editor_hint():
				if resource.amount == resource.max_amount or resource.amount == 0:
					visible = false
				else:
					visible = true
				
				if resource.amount < bar.value:
					bar.value -= BAR_FILL_CHANGE_PERCENTAGE_PER_SECOND * (bar.max_value/100) * delta
				elif resource.amount > bar.value:
					bar.value += BAR_FILL_CHANGE_PERCENTAGE_PER_SECOND * (bar.max_value/100) * delta

	
