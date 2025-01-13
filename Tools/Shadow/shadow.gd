@tool
class_name Shadow extends Sprite2D

const SHADOW_PIXEL_SCALE = 32
@export var sprite: Sprite2D
@export var shadow_color: Color = Color(0, 0, 0, 0.5) # Dark and semi-transparent

func _process(delta):
	# Copy texture and properties from the original sprite
	flip_h = sprite.flip_h
	flip_v = sprite.flip_v
	hframes = sprite.hframes
	vframes = sprite.vframes
	frame = sprite.frame
	modulate = shadow_color
	global_position = sprite.get_parent().global_position
	offset.y = sprite.offset.y + sprite.texture.get_size().y/3
	offset.x = sprite.offset.x - sprite.texture.get_size().x/2
	scale = sprite.scale * sprite.texture.get_size().x / SHADOW_PIXEL_SCALE
