extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().has_node("Sprite2D"):
		var parent_sprite = get_parent().get_node(("Sprite2D")) as Sprite2D
		offset = parent_sprite.offset