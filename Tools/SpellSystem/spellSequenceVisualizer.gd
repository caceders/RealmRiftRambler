extends Node

const SPRITE_SIZE = Vector2(.5, .5)
const SPRITE_HEIGHT = 15

@export var enable: bool = true

@export var key_sequence_recoder: keySequenceRecoder

@export var left_texture: Texture
@export var right_texture: Texture
@export var up_texture: Texture
@export var down_texture: Texture

func _process(_delta):
	# Remove previous sprites
	for child in get_children():
		child.queue_free()

	self.visible = enable
	var sequence = key_sequence_recoder.sequence
	for direction_index in range(sequence.size()):
		var texture = null

		match sequence[direction_index]:
			"left":
				texture = left_texture
			"right":
				texture = right_texture
			"up":
				texture = up_texture
			"down":
				texture = down_texture

		var sprite = Sprite2D.new()
		add_child(sprite)
		sprite.texture = texture
		sprite.scale = SPRITE_SIZE
		sprite.position.y = - SPRITE_HEIGHT
		# Set x position so that all of them are lined up
		sprite.position.x = (sprite.texture.get_size().x/1.5) * (direction_index - (float(sequence.size() - 1)/2))
