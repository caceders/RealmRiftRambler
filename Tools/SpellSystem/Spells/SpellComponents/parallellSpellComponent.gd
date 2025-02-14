class_name ParallellSpellComponent extends SpellComponent

@export var spell_components: Array[SpellComponent] = [null]

func activate(spell_caster: SpellCaster):
	var promises = []
	for component in spell_components:
		var promise = Promise.new()
		async_activate(component, spell_caster, promise)
		promises.append(promise)
	await Promise.async_all(promises)

func async_activate(spell_component: SpellComponent, spell_caster: SpellCaster, promise: Promise):
	await spell_component.activate(spell_caster)
	promise.resolve()
