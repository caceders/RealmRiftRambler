class_name HealSpellComponent extends SpellComponent

@export var heal_amount: float = 10

@export var target: AffectEntity = AffectEntity.TARGET

func activate(spell_caster: SpellCaster):
	var health: DamageReceiver
	match target:
		AffectEntity.CASTER:
			if spell_caster.parent != null:
				health = spell_caster.parent.get_node("DamageReceiver") as DamageReceiver
		AffectEntity.TARGET:
			if spell_caster.target != null:
				health = spell_caster.target.get_node("DamageReceiver") as DamageReceiver
				if health != null:
					health.add_to_pool(heal_amount)

	if health != null:
		health.add_to_pool(heal_amount)
