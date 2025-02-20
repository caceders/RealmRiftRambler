class_name Item extends Resource

@export var icon_texture: Texture
@export var sprite_texture: Texture
@export var name: String = "Item"
@export var use_function: Callable
@export var consume_on_use: bool = true

func use():
    if use_function != null:
        use_function.call()