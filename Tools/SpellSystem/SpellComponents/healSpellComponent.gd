class_name HealSpellComponent extends SpellComponent

@export var heal_amount: float = 10

@export var target: AffectEntity = AffectEntity.TARGET

func activate(spell_caster: SpellCaster):
	match target:
		AffectEntity.CASTER:
			if spell_caster.parent != null:
				var health = spell_caster.parent.get_node("DamageReceiver") as DamageReceiver
				if health != null:
					health.add_to_pool(heal_amount)
		AffectEntity.TARGET:
			if spell_caster.target != null:
				var health = spell_caster.target.get_node("DamageReceiver") as DamageReceiver
				if health != null:
					health.add_to_pool(heal_amount)
		_:
			pass
