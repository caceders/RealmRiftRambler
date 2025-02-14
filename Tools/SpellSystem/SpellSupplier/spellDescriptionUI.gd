class_name SpellDescriptionUI extends Node2D

@export var spell_image: TextureRect
@export var description: Label
@export var cost: Label
@export var bottom: Container
@export var checkmark: TextureRect

@export var spell_description_image: Texture2D:
	get:
		return spell_image.texture
	set(value):
		if spell_image:
			spell_image.set_texture(value)

@export var spell_description_text: String:
	get:
		return description.text
	set(value):
		if description:
			description.text = value

@export var spell_cost: int:
	get:
		return int(cost.text)
	set(value):
		if cost:
			cost.text = var_to_str(value)

@export var is_activated: bool:
	get:
		return _is_activated
	set(value):
		if value:
			if bottom:	
				bottom.visible = false
			if checkmark:
				checkmark.visible = true
		else:
			if bottom:
				bottom.visible = true
			if checkmark:
				checkmark.visible = false
		_is_activated = value

var _is_activated: bool = false
