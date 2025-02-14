class_name SpellSupplier extends Interactable

const JUMBLE_TEXT_LETTERS = ["?"]

@export var interaction_animation_player: AnimationPlayer
@export var spell_description_ui: SpellDescriptionUI
@export var popup_animation_player: AnimationPlayer

@export var sprite: Sprite2D
@export var pre_activation_sprite: Texture
@export var post_activation_sprite: Texture

@export var popup_area: Area2D	

@export var spell: Spell
@export var cost: int = 100

var activated: bool = false:
	get:
		return _activated
	set(value):
		if value:
			sprite.texture = post_activation_sprite
			spell_description_ui.spell_description_text = keycode

		else:
			sprite.texture = pre_activation_sprite
			spell_description_ui.spell_description_text = jumble_text

		spell_description_ui.is_activated = value
		_activated = value

var _activated: bool = false
var keycode: String:
	get:
		if _keycode != "":
			return _keycode
		else:
			for key in SequenceDecoder._keycodes:
				if SequenceDecoder._keycodes[key] == spell:
					_keycode = key
					return _keycode
		return "ERROR_NO_KEYCODE"
	set(value):
		return

var _keycode: String = "" 
var jumble_text: String

func _ready():
	popup_animation_player.play("Disappear")
	var bodies_in_popup_area = popup_area.get_overlapping_bodies()
	for body in bodies_in_popup_area:
		if "Player" in body.get_groups():
			popup_animation_player.stop()
			popup_animation_player.play("Appear")
	
	
	if not _activated:
		jumble_text = ""
		for letter in keycode:
			jumble_text += JUMBLE_TEXT_LETTERS.pick_random()

		spell_description_ui.spell_description_text = jumble_text
	spell_description_ui.is_activated = _activated
	spell_description_ui.spell_description_image = spell.spell_image

func interact(interactor: Interactor):
	if activated:
		return
	if not interactor.get_parent().has_node("ResourceCollector"):
		return
	
	var resource_collector = interactor.get_parent().get_node("ResourceCollector")
	if resource_collector.amount < cost:
		interaction_animation_player.play("tooExpensive")
	else:
		interaction_animation_player.play("activate")
		activated = true
		resource_collector.amount -= cost
		
func show_popup():
	popup_animation_player.play("Appear")

func hide_popup():
	popup_animation_player.play("Disappear")

func _on_popup_area_body_entered(body:Node2D):
	if "Player" in body.get_groups():
		show_popup()

func _on_popup_area_body_exited(body:Node2D):
	if "Player" in body.get_groups():
		hide_popup()
