@tool
class_name Shadow extends Sprite2D
## Shadow is 32 bit while standard sprites are 8, map the shadow scale to the standard scale
const SHADOW_PIXEL_SCALE = 4

const INVERSE_SKEW_AMOUNT = 10

@onready var sprite: Sprite2D = self.get_parent().get_node("Sprite2D")
@export var shadow_color: Color = Color(0, 0, 0, 0.5) # Dark and semi-transparent

func _process(delta):
	# Copy texture and properties from the original sprite
	modulate = shadow_color
	global_position = sprite.get_parent().global_position
	var difference_factor_x = sprite.texture.get_size().y / texture.get_size().x
	var difference_factor_y = sprite.texture.get_size().x / texture.get_size().y

	# Scale the shadow appropriately
	scale.x = difference_factor_x
	scale.y = difference_factor_y / 3

	## Place the shadow on the lowest part of the entity
	offset = sprite.offset
	offset.y += sprite.texture.get_size().y/( 2 *difference_factor_y)

	## Skew the shadow a bit to the left
	offset.x -= sprite.texture.get_size().x/(INVERSE_SKEW_AMOUNT *difference_factor_x)

	scale.x += abs(offset.x/texture.get_size().x)
