class_name DoTimesSpellComponent extends SpellComponent

@export var spell_components: Array[SpellComponent] = [null]
@export var times: int = 1

func activate(spell_caster: SpellCaster):
	for i in range(times):
		for component in spell_components:
			await component.activate(spell_caster)