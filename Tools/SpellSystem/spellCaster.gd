class_name SpellCaster extends Node2D

@onready var parent = get_parent()
@export var target: Node2D = null

func cast(spell: Spell):
	spell.cast(self)
