class_name Spell extends Resource

@export var spell_image: Texture

@export var spell_components: Array[SpellComponent] = [null]
var _active_component_index = 0


func cast(spell_caster: SpellCaster):
	for component in spell_components:
		# Needs to be a copy to seperate calls from multiple spellcasts
		var component_copy = component.duplicate(true)
		await component_copy.activate(spell_caster)
	
